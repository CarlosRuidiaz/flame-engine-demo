// Prueba de PaginaJuego con hot reload: la pantalla de inicio no debe volver
// a aparecer cuando se recarga el código en medio de una partida.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flame_engine_demo/features/juego/juego_dependencies.dart';
import 'package:flame_engine_demo/features/juego/ui/views/juego_corredor.dart';
import 'package:flame_engine_demo/features/juego/ui/views/pagina_juego.dart';

void main() {
  setUp(registerJuego);
  tearDown(Get.reset);

  JuegoCorredor juegoDe(WidgetTester tester) => tester
      .widget<GameWidget<JuegoCorredor>>(find.byType(GameWidget<JuegoCorredor>))
      .game!;

  testWidgets('el hot reload no vuelve a mostrar la pantalla de inicio', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PaginaJuego()));
    final juego = juegoDe(tester);
    expect(juego.overlays.isActive('inicio'), isTrue);

    // Empieza la partida: el mundo quita la pantalla de inicio.
    juego.overlays.remove('inicio');

    // Hot reload: Flutter vuelve a ensamblar y reconstruir toda la pantalla.
    tester.binding.buildOwner!.reassemble(tester.binding.rootElement!);
    await tester.pump();

    expect(juegoDe(tester), same(juego));
    expect(juego.overlays.isActive('inicio'), isFalse);
    expect(juego.overlays.isActive('controles'), isTrue);
  });
}
