shader_type canvas_item;

render_mode unshaded;

uniform float score_mask : hint_range(0.0, 1.0, 0.2);

uniform vec3 score_color : source_color = vec3(1.0);

void vertex() {
}

void fragment() {
	
	float gradient = cos(UV.x * 8.0 * TAU);
	float scoring_mask = float(score_mask > UV.x);
	float f_mask = clamp(gradient * scoring_mask * UV.x, 0.0, 1.0);
	COLOR = vec4(score_color, f_mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
