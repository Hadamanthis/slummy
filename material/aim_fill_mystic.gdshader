shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.75, 1.0, 1.0, 0.8);
uniform vec4 edge_color : source_color = vec4(0.0, 0.85, 1.0, 0.15);
uniform float pulse_speed = 5.0;
uniform float flow_speed = 0.8;
uniform float texture_strength = 0.85;

void fragment() {
	vec2 moving_uv = UV;
	moving_uv.x -= TIME * flow_speed;

	vec4 streak = texture(TEXTURE, moving_uv);

	float center = 1.0 - abs(UV.y - 0.5) * 2.0;
	float soft_center = smoothstep(0.0, 1.0, center);
	
	float flow = sin((UV.x * 18.0) - (TIME * pulse_speed)) * 0.5 + 0.5;
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	
	vec4 color = mix(edge_color, core_color, soft_center);
	color.rgb = mix(color.rgb, streak.rgb, streak.a * texture_strength);
	color.rgb += (pulse * 0.12) + (flow * streak.a * 0.18);
	color.a *= mix(0.75, 1.15, pulse);
	color.a = max(color.a, streak.a * soft_center);
	
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
