import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../viewmodels/partida_controller.dart';
import 'juego_corredor.dart';
import 'overlays/boton_depuracion.dart';
import 'overlays/pantalla_inicio.dart';
import 'overlays/pantalla_perdiste.dart';

// Los overlays son widgets normales de Flutter dibujados encima del juego.
// Están aquí afuera para que las pruebas usen exactamente los mismos.
final Map<String, OverlayWidgetBuilder<JuegoCorredor>> overlaysDelJuego = {
  'inicio': (context, game) => const PantallaInicio(),
  'controles': (context, game) => BotonDepuracion(game: game),
  'perdiste': (context, game) => PantallaPerdiste(game: game),
};

const List<String> overlaysIniciales = ['inicio', 'controles'];

// La pantalla del juego: el juego es un widget más dentro de la app de Flutter.
// Es StatefulWidget para crear el juego una sola vez: así el hot reload
// reconstruye la pantalla sin reiniciar la partida.
class PaginaJuego extends StatefulWidget {
  const PaginaJuego({super.key});

  @override
  State<PaginaJuego> createState() => _PaginaJuegoState();
}

class _PaginaJuegoState extends State<PaginaJuego> {
  late final JuegoCorredor juego = JuegoCorredor(
    partida: Get.find<PartidaController>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorOscuro,
      body: GameWidget<JuegoCorredor>(
        game: juego,
        loadingBuilder: (context) =>
            const Center(child: CircularProgressIndicator(color: colorAcento)),
        overlayBuilderMap: overlaysDelJuego,
        initialActiveOverlays: overlaysIniciales,
      ),
    );
  }
}
