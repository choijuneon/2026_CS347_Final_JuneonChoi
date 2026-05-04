shader_type sky;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black;

void sky() {
	COLOR = texture(source_panorama, SKY_COORDS).rgb / 500.0;
}
