shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // === 关键修复：正确处理 sRGB 到 Linear ===
    vec3 base = pow(tex.rgb, vec3(2.2));           // sRGB → Linear
    
    // 应用 Modulate（保持正常变色和透明度）
    vec3 color = base * COLOR.rgb;
    
    // 闪白效果
    color = mix(color, pow(flash_color.rgb, vec3(2.2)), flash_amount);
    
    // 转回 sRGB 输出
    COLOR.rgb = pow(color, vec3(1.0/2.2));
    COLOR.a = tex.a * COLOR.a;
}