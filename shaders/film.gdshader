// Full-screen "film print" pass: Fincher-style grade (green shadows, warm
// sickly highlights), 24 fps grain, gate weave, scratches, dust, vignette,
// and the cigarette burn that marks a reel change.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float grain_amount = 0.07;
uniform float vignette_amount = 0.55;
uniform float desaturate = 0.22;
uniform float contrast = 1.1;
uniform vec3 shadow_tint = vec3(0.02, 0.055, 0.04);
uniform vec3 highlight_tint = vec3(1.0, 0.96, 0.86);
uniform float exposure = 1.0;
uniform float flicker = 0.035;
uniform vec2 shake = vec2(0.0);
uniform float glitch = 0.0;
uniform float mono = 0.0;
uniform float scanlines = 0.0;
uniform float burn = 0.0;
uniform float aberration = 0.0012;
uniform float scratches = 1.0;
uniform float seed = 0.0;
uniform float red_flash = 0.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = SCREEN_UV + shake;
	if (glitch > 0.0) {
		float band = floor(uv.y * 30.0);
		float r = hash(vec2(band, floor(seed * 3.0)));
		if (r < glitch * 0.6) {
			uv.x += (hash(vec2(band, seed)) - 0.5) * 0.12 * glitch;
		}
	}
	float ab = aberration + glitch * 0.006;
	vec3 col;
	col.r = texture(screen_tex, uv + vec2(ab, 0.0)).r;
	col.g = texture(screen_tex, uv).g;
	col.b = texture(screen_tex, uv - vec2(ab, 0.0)).b;

	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(lum), desaturate);
	col = (col - 0.5) * contrast + 0.5;
	col += shadow_tint * (1.0 - smoothstep(0.0, 0.6, lum));
	col *= mix(vec3(1.0), highlight_tint, smoothstep(0.4, 1.0, lum));

	if (mono > 0.0) {
		float l = dot(col, vec3(0.299, 0.587, 0.114));
		col = mix(col, vec3(l) * vec3(0.9, 1.0, 0.93), mono);
	}
	if (scanlines > 0.0) {
		float s = sin(SCREEN_UV.y * 720.0 * 3.14159) * 0.5 + 0.5;
		col *= 1.0 - scanlines * 0.3 * s;
		col += (hash(vec2(floor(SCREEN_UV.y * 240.0), seed)) - 0.5) * 0.05 * scanlines;
	}

	float g = hash(SCREEN_UV * vec2(1280.0, 720.0) + fract(seed * 0.618) * 97.0) - 0.5;
	col += g * grain_amount * (1.25 - lum);
	col *= exposure * (1.0 + (hash(vec2(seed, 7.0)) - 0.5) * flicker);

	if (scratches > 0.0) {
		float fs = floor(seed);
		float sx = hash(vec2(fs, 11.0));
		float on = step(0.86, hash(vec2(fs, 3.0)));
		float line = smoothstep(0.0011, 0.0, abs(SCREEN_UV.x - sx));
		col = mix(col, vec3(0.82, 0.82, 0.76), line * on * 0.16 * scratches);
		vec2 dp = vec2(hash(vec2(fs, 1.0)), hash(vec2(fs, 2.0)));
		float speck = smoothstep(0.0045, 0.0, length((SCREEN_UV - dp) * vec2(1.7778, 1.0)));
		col = mix(col, vec3(0.04), speck * step(0.55, hash(vec2(fs, 5.0))) * scratches);
	}

	vec2 d = (SCREEN_UV - 0.5) * vec2(1.0, 0.85);
	col *= 1.0 - smoothstep(0.25, 0.85, length(d)) * vignette_amount;
	col = mix(col, vec3(0.55, 0.0, 0.0), red_flash * 0.35);

	if (burn > 0.0) {
		vec2 bp = (SCREEN_UV - vec2(0.905, 0.125)) * vec2(1.7778, 1.0);
		float n = vnoise(bp * 60.0 + seed) * 0.012;
		float r = length(bp) + n;
		float core = smoothstep(0.034, 0.027, r);
		float ring = smoothstep(0.043, 0.034, r) - core;
		col = mix(col, mix(col, vec3(0.93, 0.89, 0.76), 0.85), core * burn);
		col = mix(col, vec3(0.04, 0.02, 0.01), ring * burn);
	}
	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
