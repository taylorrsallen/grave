shader_type spatial;
render_mode depth_prepass_alpha, depth_draw_opaque, unshaded, cull_disabled;

uniform sampler2D noiseTexture;
uniform bool isSoft = false;
uniform float speed : hint_range(0.0, 1.0) = 0.1;
uniform float brightness: hint_range(0.0, 2.0) = 0.1;
uniform float threshold : hint_range(0.0, 2.0) = 0.1;
uniform float fluffiness : hint_range(0.0, 2.0) = 0.1;
uniform vec2 wind_direction = vec2(0.5, 0.5);
uniform bool shadow_layer = false;

void fragment() {
    // Mixing two time-shifted textures to create fluffiness
	vec2 move_1 = TIME * 2.5 * speed * 0.01 * -wind_direction;
	vec2 move_2 = TIME * (2.5 + fluffiness * 3.0) * speed * 0.01 * -wind_direction;

    vec4 noise1 = texture(noiseTexture, mod(UV + move_1, 0.0));
    vec4 noise2 = texture(noiseTexture, mod(UV + move_2, 0.0));
    vec4 combinedNoise = noise1 + noise2;

    if (isSoft == true) {
        // Creating smooth transitions using smoothstep
        combinedNoise.a = combinedNoise.r;
        ALBEDO = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise).rgb * brightness;
        ALPHA =  smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise).a;
		//
		//ALPHA_HASH_SCALE = 0.0;
    } else {
        // Creating hard transitions
        ALBEDO = combinedNoise.rgb * brightness;
        if (combinedNoise.r < threshold) {
            ALPHA = 0.0;
        } else {
            ALPHA = 1.0;
        }
    }
}