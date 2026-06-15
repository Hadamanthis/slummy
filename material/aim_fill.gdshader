shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.25, 1.0, 1.0, 0.35);
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.75);
uniform float pulse_speed = 4.0;
uniform float pulse_strength = 0.25;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	
	vec4 color = base_color;
	color.rgb = mix(base_color.rgb, glow_color.rgb, pulse * pulse_strength);
	color.a = mix(base_color.a, glow_color.a, pulse * 0.35);
	
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
