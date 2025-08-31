shader_type canvas_item;

/* Cono volumétrico 2D “soft” */
uniform float length : hint_range(100.0, 1200.0) = 520.0;     // largo del haz
uniform float half_angle_deg : hint_range(5.0, 60.0) = 18.0;  // semi-apertura
uniform float edge_softness : hint_range(0.01, 1.0) = 0.25;   // suavidad del borde
uniform float inner_fade : hint_range(0.0, 1.0) = 0.25;       // atenúa cerca del origen
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 0.55); // color/alpha del haz

void fragment() {
	// UV: asumimos el Sprite2D con "Region disabled" y tamaño 1x1 escalado vía "scale".
	// Construimos coordenadas locales en [-1..1] horizontal y [-0.5..0.5] vertical.
	vec2 p = UV;
	p.x = p.x * 2.0 - 0.0;     // 0..2 (usaremos solo 0..1 a la derecha)
	p.y = p.y - 0.5;           // -0.5..0.5

	// Solo dibujamos a la derecha (cono hacia +X local del Sprite).
	if (UV.x < 0.0 || UV.x > 1.0) {
		COLOR = vec4(0.0);
		return;
	}

	// Mapeamos UV.x (0..1) a distancia 0..length
	float x = UV.x;                // 0..1
	float dist = x;                // distancia relativa
	float angle = atan(abs(p.y) / max(x, 1e-4)); // ángulo respecto al eje +X

	float half_angle = radians(half_angle_deg);
	// máscara angular: 1 en el centro, 0 fuera del cono, con suavizado
	float edge = smoothstep(half_angle, half_angle*(1.0 - edge_softness), angle);

	// fade hacia el final y salida suave al origen
	float tail = smoothstep(0.0, 1.0, 1.0 - x);     // cae al final
	float near = 1.0 - inner_fade * (1.0 - smoothstep(0.0, 0.25, x)); // atenúa cerca

	float a = edge * tail * near;
	COLOR = vec4(tint.rgb, tint.a * a);
}
