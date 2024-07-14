shader_type spatial;

varying vec3 vertex_interpolated;

void vertex() {
	vertex_interpolated = VERTEX;
}

void fragment() {
	// vertex_interpolated.x = 42.0; // This crash the editor
}