shader_type spatial;
render_mode shadows_disabled, cull_disabled;

#include "proximity-fade.gdshaderinc"
// Param has no meaning, declares depth texture for internal func 
USE_DEPTH_TEXTURE(1) 

uniform float metallic = 0.0;
uniform float roughness = 0.02;
uniform float alpha = 0.75;

// Colors
uniform vec4 primary_color : source_color;
uniform vec4 sink_color : source_color;
uniform vec4 frensel_color : source_color;

// Wave Foam
uniform sampler2D wavefoam_texture_a;
uniform sampler2D wavefoam_texture_b;
uniform float wavefoam_a_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float wavefoam_b_strength : hint_range(0.0, 1.0, 0.01) = 0.1;

// Ripple
uniform sampler2D ripple_noise;
uniform vec3 ripple_color : source_color;
uniform float ripple_strength : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float ripple_scale = 0.5;
uniform float ripple_freq = 2.5;
uniform float ripple_speed = 1.5;

// Wave Variabels
uniform sampler2D wave;
uniform float wave_speed: hint_range(0.0, 0.2, 0.005) = 0.025; //Speed of waves across time
uniform float noise_scale = 10.0;
uniform float height_scale = 0.05;

// Wave Normal Maps
uniform sampler2D normalmap_a : hint_normal; 
uniform sampler2D normalmap_b : hint_normal; 
uniform float normalmap_a_strength : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normalmap_b_strength : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform vec2 movement_direction = vec2(0.2,0.1);
uniform float movement_strength = 0.12;

// UV Settings
uniform float uv_scale = 1.0;

// Restore old version Variables
uniform sampler2D depth_texture: hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

// Depth Variables
uniform float depth_distance: hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law: hint_range(0.0, 20.0, 0.1) = 12.0; //Attenuation of Light
uniform float water_transparency: hint_range(0.0, 1.0, 0.01) = 0.0;

// Refraction
uniform float refraction_strength : hint_range(0.0, 0.8, 0.001) = 0.5;

//Varying Variables
varying float height;
varying vec3 world_pos;

float fresnel(float amount, vec3 normal, vec3 view){ // higher amount gives the edge more power 
	// value gets higher when the camera angle get more perpendicular to the object
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + TIME * wave_speed).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	// Time calculations for direction (normal map) movement
	vec2 uv = UV * uv_scale;
	vec2 uv_movement = movement_direction * TIME * movement_strength;
	
	//Blend normal maps into one
	vec3 moving_normalmap_a = texture(normalmap_a, uv + uv_movement).rgb * normalmap_a_strength;
	vec3 moving_normalmap_b = texture(normalmap_b, uv - uv_movement).rgb * normalmap_b_strength;
	vec3 normalmap = moving_normalmap_a + moving_normalmap_b;
	
	// Create refraction with normal map
	vec3 refraction_normalmap = normalmap * 2.0 - (normalmap_a_strength + normalmap_b_strength);
	vec3 refraction_normal = mix(NORMAL, TANGENT * refraction_normalmap + BINORMAL
	 * refraction_normalmap + NORMAL * refraction_normalmap, 1.0);
	vec2 refraction_offsets = SCREEN_UV - refraction_normal.xy * refraction_strength;
	
	// Get Depth and Screen Textures
	float depth_clean = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	float depth = textureLod(depth_texture, refraction_offsets, 0.0).r;
	vec3 screen = textureLod(screen_texture, refraction_offsets, 0.0).rgb;
	
	// Get Depth in World Position (Y)
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec3 ndc_clean = vec3(SCREEN_UV * 2.0 - 1.0, depth_clean); // Undistorted UV
	
	//Get Depth in View Matrix
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z + VERTEX.z; //Checks if object is in front of water plane
	
	vec4 world;
	
	//If object is in front, use undistorted UVs
	if (linear_depth < 0.00001) {
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc_clean, 1.0);
	}
	else {
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	}
	
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	
	// Set Depth Blend and adjust with Beer's Law
	float depth_blend = clamp((vertex_y - depth_texture_y) / depth_distance, 0.0, 1.0);
	depth_blend = exp(-depth_blend * beers_law);
	
	// Set depth color mix from depth blend and get final color mix using screen texture
	vec3 depth_color = mix(primary_color, sink_color, depth_blend).rgb;
	vec3 refraction_texture = textureLod(screen_texture, refraction_offsets, ROUGHNESS * 2.0).rgb;
	vec3 transparency_color = mix(depth_color, refraction_texture, water_transparency * depth_blend);
	
	// 0(edge) =< fresnel =< 1(front)
	float fresnel = fresnel(2.0, NORMAL, VIEW);
	
	vec3 fresnel_color = mix(transparency_color, frensel_color.rgb, fresnel);
	
	// Overlaying foam texture over water
	vec3 moving_foam_a = texture(wavefoam_texture_a, uv + uv_movement).rgb * wavefoam_a_strength;
	vec3 moving_foam_b = texture(wavefoam_texture_b, uv - uv_movement).rgb * wavefoam_b_strength;
	vec3 foam_texture = moving_foam_a + moving_foam_b;
	
	vec3 foam_color = mix(fresnel_color, foam_texture, 0.5);
	
	// Adding Ripple

	vec3 ripple_texture = vec3(1.0) - PROXIMITY_FADE(ripple_scale);
	
	vec3 moving_ripple = ripple_texture + vec3(TIME * ripple_speed);
	moving_ripple = abs(sin(moving_ripple * ripple_freq));
	vec3 ripple_mask = abs(texture(ripple_noise, refraction_offsets).rgb - vec3(0.5));
	moving_ripple *= pow(ripple_texture, vec3(2.0)) * ripple_mask;
	vec3 final_color = foam_color + moving_ripple * ripple_strength * ripple_color;
	
	ALBEDO = final_color;
	ALPHA = alpha;
	METALLIC = metallic;
	ROUGHNESS = roughness * (1.0 - fresnel);
	NORMAL_MAP = normalmap;
}