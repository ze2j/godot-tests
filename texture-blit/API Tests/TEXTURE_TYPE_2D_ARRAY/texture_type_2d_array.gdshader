shader_type spatial;
render_mode unshaded;

uniform sampler2DArray tex : source_color, filter_nearest_mipmap, repeat_disable;
uniform int layer = 0;
uniform int mipmap = 0;

void fragment() {
    ALBEDO = textureLod(tex, vec3(UV, float(layer)), float(mipmap)).rgb;
}