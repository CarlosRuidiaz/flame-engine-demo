import 'package:flutter/material.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/panel_pixel.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    // IgnorePointer deja pasar el toque al juego, que es quien lo recibe.
    return const IgnorePointer(
      child: Center(
        child: PanelPixel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("LOLA'S ADVENTURE", style: estiloTitulo),
              SizedBox(height: 12),
              Text('Toca para empezar', style: estiloTexto),
            ],
          ),
        ),
      ),
    );
  }
}
