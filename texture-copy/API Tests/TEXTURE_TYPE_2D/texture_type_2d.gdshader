shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_nearest_mipmap, repeat_disable;
uniform int mipmap = 0;

void fragment() {
    ALBEDO = textureLod(tex, UV, float(mipmap)).rgb;
}
