shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    if (flash_amount > 0.0) {
      vec4 tex = texture(TEXTURE, UV);
      vec3 color = tex.rgb;
      // 闪白效果
      color = mix(color, pow(vec3(1.0, 1.0, 1.0), vec3(2.2)), flash_amount);
      COLOR.rgb = color;
    }
}
