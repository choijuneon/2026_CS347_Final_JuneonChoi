shader_type spatial;
render_mode blend_mix;

uniform sampler2D wave_noise;
uniform float height_scale = 1.0;
uniform float wave_speed = 1.0;

uniform vec4 albedo_color : source_color;
uniform sampler2D normal_map;

uniform bool enable_emission = false;
uniform vec3 emission_color : source_color;
uniform float emission_strength = 1.0;

uniform float noise_sample_size = 1.0;
uniform float wobble_scale = 1.0;
uniform float upDown_scale = 1.0;
uniform float time_scale = 1.0;

uniform float y_offset = 0.0;

uniform bool enable_wobble = false;

const vec3 center = vec3(0.0);

float fresnel(vec3 normal, mat4 camera_matrix){
	vec3 view_direction_world = (camera_matrix * vec4(0.0,0.0,1.0,0.0)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal,0.0)).xyz;
	
	float d = dot(view_direction_world,normal_world);
	d = abs(d);
	d = clamp(d,0.0,1.0);
	
	return 1.0 - d;
}

void vertex() {
	//wave
	float height = texture(wave_noise, VERTEX.xz * noise_sample_size + vec2(TIME) * wave_speed).r;
	VERTEX += NORMAL * height * height_scale;
	
	vec3 pos = VERTEX - center;
	float angle = atan(pos.y, pos.x);
	
	//wobble (for oil)
	if (enable_wobble) {
	float wobble_movement_a = wobble_scale * sin(TIME * time_scale - angle);
	float wobble_movement_b = wobble_scale * cos(TIME * time_scale - angle);
	VERTEX.y += (wobble_movement_a + wobble_movement_b) / 2.0;
	}
	
	//bounce
	float upDown_movement = upDown_scale * sin(TIME * time_scale);
	VERTEX.y += abs(upDown_movement) + y_offset;
}

void fragment() {
	ALBEDO = albedo_color.rgb;
	ALPHA = fresnel(NORMAL,INV_VIEW_MATRIX);
	ROUGHNESS = 0.05;
	NORMAL_MAP = texture(normal_map,UV).rgb;
	if (enable_emission){
		EMISSION = emission_color * emission_strength;
	}
}
