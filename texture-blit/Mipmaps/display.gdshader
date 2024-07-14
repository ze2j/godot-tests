shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_nearest_mipmap, repeat_disable;
instance uniform int lod = 0;

void vertex() {
}

void fragment() {
    ALBEDO = textureLod(tex, UV, float(lod)).rgb;
}
