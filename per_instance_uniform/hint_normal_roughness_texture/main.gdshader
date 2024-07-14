shader_type spatial;
// https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html

#define USE_SHADER_INCLUDE

#ifdef USE_SHADER_INCLUDE
#include "hint_normal_roughness_texture.gdshaderinc"
#else
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;
#endif


void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float screen_roughness = texture(normal_roughness_texture, SCREEN_UV).w;
	vec3 screen_normal = texture(normal_roughness_texture, SCREEN_UV).xyz;
	screen_normal = screen_normal * 2.0 - 1.0;

	ALBEDO = vec3(screen_roughness);
	//ALBEDO = screen_normal;
}
