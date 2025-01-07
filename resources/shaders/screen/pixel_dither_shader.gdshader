shader_type canvas_item;

const mat4 BAYER4 = mat4(
	vec4(0, 8, 2, 10),
	vec4(12, 4, 14, 6),
	vec4(3, 11, 1, 9),
	vec4(15, 7, 13, 5)
);

uniform float SPREAD : hint_range(0, 256) = 0.1;
uniform int COLORS : hint_range(0, 256) = 16;
uniform float PIXEL_SIZE : hint_range(1.0, 64.0) = 2;

// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 i_res = 1.0 / SCREEN_PIXEL_SIZE;

	vec2 res_pixel_size = vec2(1.0 / i_res.x, 1.0 / i_res.y);
	vec2 cell_size = vec2(PIXEL_SIZE * res_pixel_size.x, PIXEL_SIZE * res_pixel_size.y);
	vec2 uv = vec2(cell_size.x * floor(SCREEN_UV.x / cell_size.x), cell_size.y * floor(SCREEN_UV.y / cell_size.y));
	vec2 frag = vec2(cell_size.x * floor(FRAGCOORD.x / cell_size.x), cell_size.y * floor(FRAGCOORD.y / cell_size.y));

	float dither_scale = 1.0 / PIXEL_SIZE;
	vec2 coord = SCREEN_UV * vec2(textureSize(screen_texture, 0)) * dither_scale;

	int x = int(coord.x) % 4;
	int y = int(coord.y) % 4;
	float m = BAYER4[x][y] * 0.0625 - 0.5;
	vec4 color = textureLod(screen_texture, uv, 0.0) + SPREAD * m;
	color = floor(color * float(COLORS - 1) + 0.5) / float(COLORS - 1);
	color.a = 1.0;
	COLOR = color;
}