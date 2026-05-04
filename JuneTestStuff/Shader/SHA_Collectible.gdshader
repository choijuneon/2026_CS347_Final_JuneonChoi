shader_type spatial;

uniform vec3 emission_color : source_color;
uniform float emission_strength = 1.0;
uniform float wobble_scale = 1.0;
uniform float upDown_scale = 1.0;
uniform float time_scale = 1.0;
uniform float y_offset = 0.0;
const vec3 center = vec3(0.0);

void vertex() {
	vec3 pos = VERTEX - center;
	float angle = atan(pos.y, pos.x);
	float wobble_movement_a = wobble_scale * sin(TIME * time_scale - angle);
	float wobble_movement_b = wobble_scale * cos(TIME * time_scale - angle);
	VERTEX.y += (wobble_movement_a + wobble_movement_b) / 2.0;
	
	float upDown_movement = upDown_scale * sin(TIME * time_scale);
	VERTEX.y += abs(upDown_movement) + y_offset;
}
void fragment() {
	EMISSION = emission_color * emission_strength;
}
