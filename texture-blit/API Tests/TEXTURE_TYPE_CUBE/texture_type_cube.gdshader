shader_type spatial;
render_mode unshaded;

uniform samplerCube tex : source_color, filter_nearest_mipmap, repeat_disable;
uniform int mipmap = 0;

varying vec3 direction;

void vertex() {
	direction = VERTEX;
}

void fragment() {
 	ALBEDO = textureLod(tex, direction, float(mipmap)).rgb;
}