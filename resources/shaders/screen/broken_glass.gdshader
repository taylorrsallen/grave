shader_type canvas_item;

// Glass effect
uniform sampler2D crack_texture;
uniform vec2 refraction_offset = vec2(25.0,25.0);
uniform vec2 reflection_offset = vec2(1.0,1.0);
uniform vec4 reflection_color : source_color = vec4(0.588,0.588,0.588,0.5);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {	
	COLOR =  texture(crack_texture, UV);
	vec4 orig_color = COLOR;
	vec4 adjacent_color = texture(crack_texture, UV + TEXTURE_PIXEL_SIZE * reflection_offset);
	if (adjacent_color.a >= 1.0) {
		COLOR = reflection_color;
	} else {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + COLOR.a*(SCREEN_PIXEL_SIZE * refraction_offset));
	}
}