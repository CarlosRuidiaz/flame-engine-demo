import 'package:flutter/material.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/boton_pixel.dart';
import '../../../../../core/widgets/panel_pixel.dart';
import '../juego_corredor.dart';

class PantallaPerdiste extends StatelessWidget {
  const PantallaPerdiste({super.key, required this.game});

  final JuegoCorredor game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PanelPixel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡CHOCASTE!', style: estiloTitulo),
            const SizedBox(height: 12),
            Text('PUNTOS ${game.world.puntos.floor()}', style: estiloTexto),
            const SizedBox(height: 4),
            Text('RÉCORD ${game.world.record.floor()}', style: estiloTexto),
            const SizedBox(height: 20),
            BotonPixel(texto: 'REINTENTAR', alPresionar: game.world.reiniciar),
          ],
        ),
      ),
    );
  }
}
