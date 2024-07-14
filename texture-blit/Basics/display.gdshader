shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_nearest, repeat_disable;

void vertex() {
}

void fragment() {
    ALBEDO = texture(tex, UV).rgb;
}
