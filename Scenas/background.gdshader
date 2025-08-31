shader_type canvas_item;

void fragment() {
    // Color base del sprite
    vec4 tex_color = texture(TEXTURE, UV);

    // Aplica la luz (usa el sistema de luces 2D de Godot)
    COLOR = tex_color * LIGHT;
}
