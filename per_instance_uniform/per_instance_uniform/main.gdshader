shader_type spatial;
render_mode unshaded;
// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#uniforms

#define USE_SHADER_INCLUDE

#ifdef USE_SHADER_INCLUDE
#include "per_instance_uniform.gdshaderinc"
#else
instance uniform vec4 my_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
#endif


void fragment() {
	ALBEDO = my_color.rgb;
}

