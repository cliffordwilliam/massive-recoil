shader_type canvas_item;

uniform bool flash = false;
uniform float angle = 0.0; // radians

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec2 dir = normalize(vec2(cos(angle), sin(angle)));
	vec2 px = TEXTURE_PIXEL_SIZE;

	// Check one pixel opposite the light direction
	vec2 check_uv = UV - dir * px;
	float neighbor_alpha = texture(TEXTURE, check_uv).a;

	// Edge detection
	float edge = step(neighbor_alpha, 0.01);

	// Only apply rim if this pixel is part of the sprite
	edge *= tex.a;

	// Disable rim if flash is false
	edge *= float(flash);

	vec3 result = mix(tex.rgb, vec3(1.0), edge);

	COLOR = vec4(result, tex.a);
}