shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform vec2 global_position;
uniform vec2 camera_position;
uniform vec2 screen_size;
uniform float force;
uniform float radius;
uniform float thickness;

void fragment() {
	vec2 center = (global_position - (camera_position - screen_size / vec2(2.0, 2.0))) / screen_size;
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	// make circle
	vec2 scaled_UV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	// add hole
	float mask = (
		(1.0 - smoothstep(radius - 0.1, radius, length(scaled_UV - center)))
		* smoothstep(radius - thickness - 0.1, radius - thickness, length(scaled_UV - center))
	);
	vec2 disp = normalize(scaled_UV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}