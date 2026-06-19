shader_type canvas_item;

void fragment() {
    float seed = floor(TIME / 30.0);
    float rand = fract(sin(seed * 12345.678) * 43758.5453);
    int dir = int(rand * 4.0);

    vec2 offset;
    if (dir == 0) offset = vec2(-0.05, -0.05); // 左上
    if (dir == 1) offset = vec2( 0.05, -0.05); // 右上
    if (dir == 2) offset = vec2(-0.05,  0.05); // 左下
    if (dir == 3) offset = vec2( 0.05,  0.05); // 右下
    vec4 color = texture(TEXTURE, UV + offset * TIME);
    COLOR = color;
}