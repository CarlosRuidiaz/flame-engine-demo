import 'package:flutter/material.dart';

import '../../../../../core/widgets/boton_pixel.dart';
import '../juego_corredor.dart';

class BotonDepuracion extends StatelessWidget {
  const BotonDepuracion({super.key, required this.game});

  final JuegoCorredor game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BotonPixel(
          texto: 'VER HITBOXES',
          alPresionar: game.alternarDepuracion,
        ),
      ),
    );
  }
}
