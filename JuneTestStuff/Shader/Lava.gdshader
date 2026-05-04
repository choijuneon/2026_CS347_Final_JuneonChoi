shader_type spatial;
render_mode shadows_disabled;

// Colors
uniform vec3 primary_color : source_color;
uniform vec3 emission_color : source_color;
uniform float emission_str = 1.0;
//Textures for lava
uniform float uv_scale = 1.0;
uniform float texture_speed = 1.0;
uniform sampler2D lava_noise_a;
uniform sampler2D lava_noise_b;
uniform float lava_b_str : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D lava_noise_c;
uniform float lava_c_str : hint_range(0.0, 1.0) = 1.0;
uniform float lava_contrast = 1.0;
//Waves
uniform sampler2D wave_noise;
uniform float noise_scale : hint_range(0.1, 50.0) = 2.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 0.5;
uniform float wave_height : hint_range(0.0, 1.0) = 0.2;

//Varying Variables
varying float height;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave_noise, world_pos.xz * noise_scale + TIME * wave_speed).r;
	VERTEX.y += height * wave_height;
}

void fragment() {
	vec2 uv = world_pos.xz * uv_scale;
	vec2 uv_movement_a = vec2(TIME * texture_speed * 1.0);
	vec2 uv_movement_b = vec2(TIME * texture_speed * 1.6);
	vec2 uv_movement_c = vec2(TIME * texture_speed * 0.3);
	
	vec3 lava_texture_a = texture(lava_noise_a, uv + uv_movement_a).rgb;
	vec3 lava_texture_b = texture(lava_noise_b, uv + uv_movement_b).rgb;
	vec3 lava_texture_c = texture(lava_noise_c, uv - uv_movement_c).rgb;
	vec3 lava_texture = mix(lava_texture_a, lava_texture_b, lava_b_str);
	lava_texture = mix(lava_texture, lava_texture_c, lava_c_str);
	
	vec3 final_color = primary_color * pow(lava_texture, vec3(lava_contrast));
	
	//NORMAL_MAP = vec3(1.0) - lava_texture;
	ALBEDO = final_color.rgb;
	EMISSION = final_color.rgb * emission_str * emission_color.rgb;
	ROUGHNESS = 1.0;
}