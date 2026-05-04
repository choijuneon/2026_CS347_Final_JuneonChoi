shader_type spatial;

uniform float uv_scale = 1.0;

uniform vec3 primary_color : source_color;
uniform vec3 effect_color : source_color;
uniform float emission_str = 1.0;

uniform sampler2D magma_noise;
uniform float magma_contrast_a = 1.0;
uniform float magma_contrast_b = 1.0;

uniform float magma_threshold_a = 0.0;
uniform float magma_threshold_b = 0.0;

uniform float time_scale = 1.0;

varying vec3 final_color;
varying vec3 emission_mask;

void vertex() {
	vec2 uv = UV * uv_scale;
	vec3 magma_texture = texture(magma_noise, UV * uv_scale).rgb;
	magma_texture = pow(magma_texture, vec3(magma_contrast_a));
	
	float magma_threshold_a_movment = magma_threshold_a - abs(0.1 * sin(TIME * time_scale + time_scale));
	float magma_threshold_b_movment = magma_threshold_b - abs(0.05 * sin(TIME * time_scale));
	
    if (VERTEX.z > magma_threshold_a_movment) {
		magma_texture = pow(magma_texture, vec3(magma_contrast_a));
		
		emission_mask = magma_texture;
        
		final_color = effect_color * magma_texture * 1.0;
    }
	else if (VERTEX.z < magma_threshold_a && VERTEX.z > magma_threshold_b_movment){
		magma_texture = pow(magma_texture, vec3(magma_contrast_a));
		
		float mix_ratio = 1.0 - (VERTEX.z - magma_threshold_b_movment)/(magma_threshold_a_movment - magma_threshold_b);
		emission_mask = mix(magma_texture, vec3(0.0), mix_ratio);
        
		final_color = effect_color * magma_texture * 0.5;
		final_color = mix(final_color, primary_color, mix_ratio);
	}
	else {
		emission_mask = vec3(0.0);
		
		final_color = primary_color;
	}
}

void fragment() {
	EMISSION = emission_mask * emission_str * final_color;
	ALBEDO = final_color;
}