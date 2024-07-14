shader_type canvas_item;

#define USE_SHADER_INCLUDE

#ifdef USE_SHADER_INCLUDE
// Error expected here
#include "res://canvas_item/per_instance_uniform.gdshaderinc"
#else
// Error expected here
instance uniform vec3 my_color : source_color = vec3(1.0, 0.5, 0.0);
#endif

void fragment() {
	COLOR.rgb = my_color;
}
