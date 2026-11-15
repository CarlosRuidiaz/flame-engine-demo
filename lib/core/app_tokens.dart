import 'package:flutter/material.dart';

// Colores de la interfaz, tomados de la misma paleta de los sprites.
const Color colorOscuro = Color(0xFF120F26); // azul casi negro
const Color colorClaro = Color(0xFFF0EAFF); // lila muy claro
const Color colorAcento = Color(0xFF4FD1E0); // turquesa
const Color colorRosa = Color(0xFFFF7AB6);
const Color colorPolvo = Color(0xFFB9A7E6); // lavanda
const Color colorFondoJuego = Color(0xFF0B0B24);

const TextStyle estiloTitulo = TextStyle(
  color: colorRosa,
  fontFamily: 'monospace',
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: 4,
);

const TextStyle estiloTexto = TextStyle(
  color: colorClaro,
  fontFamily: 'monospace',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
);

const TextStyle estiloPuntos = TextStyle(
  color: colorClaro,
  fontFamily: 'monospace',
  fontSize: 26,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  shadows: [Shadow(color: colorOscuro, offset: Offset(3, 3))],
);
