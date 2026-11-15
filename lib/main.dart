// Demo de la exposición: Lola, una gata astronauta que corre y salta
// obstáculos en pixel art. El código está organizado con arquitectura limpia:
// lib/core para lo compartido y lib/features/juego con sus capas
// domain, data y ui (ver el README).

import 'package:flutter/material.dart';

import 'features/juego/juego_dependencies.dart';
import 'features/juego/ui/views/pagina_juego.dart';

// ---------------------------------------------------------------------------
// Punto de entrada: registra las dependencias y arranca la app
// ---------------------------------------------------------------------------

void main() {
  registerJuego();
  runApp(const LolaApp());
}

class LolaApp extends StatelessWidget {
  const LolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Lola's Adventure",
      debugShowCheckedModeBanner: false,
      home: PaginaJuego(),
    );
  }
}
