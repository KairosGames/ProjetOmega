shader_type canvas_item;

uniform vec3 planet_color : source_color = vec3(1.0);
uniform vec3 glow_color : source_color = vec3(0.0);

uniform float beat_value : hint_range(0.0, 1.0);

void vertex() {
}

void fragment() {
	vec3 change_color = mix(planet_color, glow_color, beat_value); 
	
	COLOR = vec4(change_color, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
