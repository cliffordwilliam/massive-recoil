shader_type canvas_item;

uniform bool flash = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (flash) {
		COLOR = vec4(1.0, 1.0, 1.0, tex_color.a);
	} else {
		COLOR = tex_color;
	}
}
