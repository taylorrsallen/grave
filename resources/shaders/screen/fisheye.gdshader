// Converted from https://www.shadertoy.com/view/td2GzW
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Anti fish eye (negative amount) / fish eye (positive)
uniform float effect_amount : hint_range(-2.5, 2.5) = 1.0;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

const mat4 BAYER4 = mat4(
	vec4(0, 8, 2, 10),
	vec4(12, 4, 14, 6),
	vec4(3, 11, 1, 9),
	vec4(15, 7, 13, 5)
);

uniform float SPREAD : hint_range(0, 256) = 0.1;
uniform int COLORS : hint_range(0, 256) = 16;
uniform float PIXEL_SIZE : hint_range(1.0, 64.0) = 2;

void fragment() {
	// glsl -> godot shader
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 fragCoord = FRAGCOORD;

	//normalized coords
	vec2 p = fragCoord.xy / iResolution.x;

	//screen proroption
	float prop = iResolution.x / iResolution.y;

	//center coords
	vec2 m = vec2(0.5, 0.5 / prop);

	//vector from center to current fragment
	vec2 d = p - m;

	// distance of pixel from center
	float r = sqrt(dot(d, d));

	float power = effect_amount;

	//radius of 1:1 effect
	float bind;

	//stick to borders
	if (power > 0.0)
		bind = sqrt(dot(m, m));
	else {
		if (prop < 1.0)
    		bind = m.x;
    	else
        	bind = m.y;
	}

	vec2 uv;
	//fisheye
	if (power > 0.0)
		uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
	//antifisheye
	else if (power < 0.0)
		uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
	//no effect for power = 1.0
	else
		uv = p;
    uv.y *= prop;

	//vec3 col = texture(SCREEN_TEXTURE, uv).rgb;

	//COLOR = vec4(col, 1.0);

	float r2 = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*r_displacement), 0.0).r;
	float g2 = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*g_displacement), 0.0).g;
	float b2 = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*b_displacement), 0.0).b;

	COLOR = floor(vec4(r2, g2, b2, 1.0) * float(COLORS - 1) + 0.5) / float(COLORS - 1);
}