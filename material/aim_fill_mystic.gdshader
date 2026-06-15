shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.75, 1.0, 1.0, 0.8);
uniform vec4 edge_color : source_color = vec4(0.0, 0.85, 1.0, 0.15);
uniform float pulse_speed = 5.0;

void fragment() {
	float center = 1.0 - abs(UV.x - 0.5) * 2.0;
	float soft_center = smoothstep(0.0, 1.0, center);
	
	float pulse = sin(TIME * pulse_speed) * cos(0.5) + 0.5;
	
	vec4 color = mix(edge_color, core_color, soft_center);
	color.rgb += pulse * 0.15;
	color.a *= mix(0.75, 1.15, pulse);
	
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
