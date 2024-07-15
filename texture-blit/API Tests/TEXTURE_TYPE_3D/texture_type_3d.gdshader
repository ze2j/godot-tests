shader_type spatial;
render_mode unshaded;

uniform sampler3D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float depth_slice = 0.5;
uniform int mipmap = 0;

void fragment() {
 	ALBEDO = textureLod(tex, vec3(UV, depth_slice), float(mipmap)).rgb;
}