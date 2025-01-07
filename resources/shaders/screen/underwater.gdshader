shader_type canvas_item;

const mat4 BAYER4 = mat4(
	vec4(0, 8, 2, 10),
	vec4(12, 4, 14, 6),
	vec4(3, 11, 1, 9),
	vec4(15, 7, 13, 5)
);

uniform float distortion_scale = 1.0;
uniform float distortion_amount = 0.01;
uniform float distortion_speed = 0.1;
uniform vec4 underwater_color: source_color;
uniform sampler2D distortion_texture : repeat_enable;

uniform float dither_spread : hint_range(0, 256) = 0.3;
uniform int dither_colors : hint_range(0, 256) = 8;
uniform float dither_pixel_size : hint_range(1.0, 64.0) = 1;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 i_res = 1.0 / SCREEN_PIXEL_SIZE;

	vec2 res_pixel_size = vec2(1.0 / i_res.x, 1.0 / i_res.y);
	vec2 cell_size = vec2(dither_pixel_size * res_pixel_size.x, dither_pixel_size * res_pixel_size.y);

	vec2 distorted_uv = SCREEN_UV + (texture(distortion_texture, UV * distortion_scale + TIME * distortion_speed).r - 0.5) * distortion_amount;

	vec2 uv = vec2(cell_size.x * floor(SCREEN_UV.x / cell_size.x), cell_size.y * floor(SCREEN_UV.y / cell_size.y));
	vec2 frag = vec2(cell_size.x * floor(FRAGCOORD.x / cell_size.x), cell_size.y * floor(FRAGCOORD.y / cell_size.y));

	float dither_scale = 1.0 / dither_pixel_size;
	vec2 coord = SCREEN_UV * vec2(textureSize(screen_texture, 0)) * dither_scale;

	int x = int(coord.x) % 4;
	int y = int(coord.y) % 4;
	float m = BAYER4[x][y] * 0.0625 - 0.5;
	vec4 color = textureLod(screen_texture, uv, 0.0) + dither_spread * m;
	color = floor(color * underwater_color * float(dither_colors - 1) + 0.5) / float(dither_colors - 1);
	color.a = 1.0;

	COLOR = color;
}