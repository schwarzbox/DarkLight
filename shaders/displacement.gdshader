shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform vec2 global_position;
uniform vec2 camera_position;
uniform vec2 screen_size;
uniform float force;
uniform float radius;
uniform float thickness;

void fragment() {
	vec2 center = (global_position - (camera_position - screen_size * vec2(0.5, 0.5)));
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	// for horizontal screens only
	center.x = center.x / screen_size.x;
	center.x = (center.x - 0.5) / ratio + 0.5;
	center.y = center.y / screen_size.y;
	// make circle
	vec2 scaled_uv = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	// add hole
	float outer = (1.0 - smoothstep(radius - 0.1, radius, length(scaled_uv - center)));
	float inner = smoothstep(radius - thickness - 0.1, radius - thickness, length(scaled_uv - center));
	float ring = outer * inner;
	vec2 disp = normalize(scaled_uv - center) * force * ring;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}