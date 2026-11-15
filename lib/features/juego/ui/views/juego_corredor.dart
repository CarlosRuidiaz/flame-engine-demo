import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/ajustes_juego.dart';
import '../../../../core/app_tokens.dart';
import '../viewmodels/partida_controller.dart';
import 'mundo_corredor.dart';

// ---------------------------------------------------------------------------
// El juego: raíz del árbol de componentes y dueño del ciclo del juego
// ---------------------------------------------------------------------------

class JuegoCorredor extends FlameGame<MundoCorredor>
    with HasCollisionDetection {
  JuegoCorredor({required PartidaController partida})
    : super(
        world: MundoCorredor(partida),
        camera: CameraComponent.withFixedResolution(
          width: anchoMundo,
          height: altoMundo,
        ),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Por defecto la cámara pone el (0, 0) del mundo en el centro.
    // Aquí se mueve a la esquina superior izquierda, como en Flutter.
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  @override
  Color backgroundColor() => colorFondoJuego;

  // Nivel 2 de la demo: muestra u oculta las cajas de todos los componentes.
  void alternarDepuracion() {
    final activar = !world.debugMode;
    for (final componente in world.descendants(includeSelf: true)) {
      componente.debugMode = activar;
    }
  }
}
