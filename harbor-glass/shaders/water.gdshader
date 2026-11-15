shader_type canvas_item;

uniform vec4 deep : source_color = vec4(0.07, 0.32, 0.46, 0.96);
uniform vec4 sheen : source_color = vec4(0.62, 0.86, 0.93, 0.45);

void fragment() {
	float ripple = sin(UV.x * 34.0 + TIME * 1.25 + UV.y * 5.0);
	float lane = fract(UV.y * 7.0 + TIME * 0.04);
	float crest = smoothstep(0.42, 0.5, abs(lane - 0.5));
	vec3 rgb = deep.rgb;
	rgb += sheen.rgb * (0.5 + 0.5 * ripple) * 0.16;
	rgb += vec3(0.20, 0.34, 0.38) * (1.0 - crest) * 0.12;
	float foam = smoothstep(0.0, 0.045, UV.y);
	COLOR = vec4(rgb, deep.a * foam);
}
