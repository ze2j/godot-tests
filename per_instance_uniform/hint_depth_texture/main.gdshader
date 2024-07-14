shader_type spatial;
// https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html

#define USE_SHADER_INCLUDE

#ifdef USE_SHADER_INCLUDE
#include "depth_texture_uniform.gdshaderinc"
#else
uniform sampler2D depth_texture : source_color, hint_depth_texture;
#endif


void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	ALBEDO.r = linear_depth;
	ALBEDO.gb = vec2(0.);
}