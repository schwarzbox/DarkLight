shader_type canvas_item;

uniform float speed = 0.024;

vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
	float sin_rotation = sin(rotation);
	float cos_rotation = cos(rotation);

	vec2 uv_result = uv - pivot;
	// calculate separately
	float uv_x = uv_result.x * cos_rotation - uv_result.y * sin_rotation;
	float uv_y = uv_result.x * sin_rotation + uv_result.y * cos_rotation;
	// create new vector from uv_x and uv_y
	uv_result = vec2(uv_x, uv_y) + pivot;
	return uv_result;
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, rotate_uv(UV, vec2(0.5), speed * TIME));
	COLOR = texture_color;
}