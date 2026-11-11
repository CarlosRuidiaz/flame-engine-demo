// Pruebas del juego JuegoCorredor usando flame_test.
// Verifican la estructura del mundo y el comportamiento básico
// sin modificar la lógica del juego.

import 'package:flame_test/flame_test.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flame_engine_demo/main.dart';

void main() {
  // Instancia de FlameTester para JuegoCorredor.
  final tester = FlameTester(JuegoCorredor.new);

  // Prueba 1: Al cargar, el mundo contiene un Jugador, un Suelo,
  // un ParallaxComponent, y el juego empieza con jugando == false.
  tester.testGameWidget(
    'el mundo contiene Jugador, Suelo y ParallaxComponent al cargar',
    setUp: (juego, _) async {
      // Esperamos a que el juego y todos sus hijos estén completamente listos.
      await juego.ready();
    },
    verify: (juego, _) async {
      final mundo = juego.world as MundoCorredor;

      // Verifica que jugando empieza en false (pantalla de inicio).
      expect(mundo.jugando, isFalse);

      // Verifica que el mundo contiene al menos un Jugador.
      expect(
        mundo.descendants().whereType<Jugador>().isNotEmpty,
        isTrue,
        reason: 'El mundo debe contener un Jugador',
      );

      // Verifica que el mundo contiene al menos un Suelo.
      expect(
        mundo.descendants().whereType<Suelo>().isNotEmpty,
        isTrue,
        reason: 'El mundo debe contener un Suelo',
      );

      // Verifica que el mundo contiene un ParallaxComponent (el fondo animado).
      expect(
        mundo.descendants().whereType<ParallaxComponent>().isNotEmpty,
        isTrue,
        reason: 'El mundo debe contener un ParallaxComponent',
      );
    },
  );

  // Prueba 2: Después de un update de 2 segundos sin jugar (jugando == false),
  // el mundo no ha creado obstáculos ni sumado puntos.
  tester.testGameWidget(
    'sin jugar, no se crean obstáculos ni se suman puntos tras 2 s',
    verify: (juego, _) async {
      final mundo = juego.world as MundoCorredor;

      // El estado inicial debe ser jugando == false.
      expect(mundo.jugando, isFalse);

      // Simulamos 2 segundos de juego sin haber iniciado la partida.
      juego.update(2.0);

      // Sin jugando, los puntos no deben haber aumentado.
      expect(mundo.puntos, equals(0.0));

      // Sin jugando, no deben haberse creado obstáculos.
      expect(
        mundo.descendants().whereType<Obstaculo>().isEmpty,
        isTrue,
        reason: 'No deben crearse obstáculos si jugando == false',
      );
    },
  );

  // Prueba 3: alternarDepuracion activa debugMode en el mundo,
  // y una segunda llamada lo desactiva.
  tester.testGameWidget(
    'alternarDepuracion activa y desactiva debugMode',
    verify: (juego, _) async {
      final mundo = juego.world as MundoCorredor;

      // Por defecto debugMode está desactivado.
      expect(mundo.debugMode, isFalse);

      // Primera llamada: debe activar el modo de depuración.
      juego.alternarDepuracion();
      expect(mundo.debugMode, isTrue);

      // Segunda llamada: debe desactivarlo de nuevo.
      juego.alternarDepuracion();
      expect(mundo.debugMode, isFalse);
    },
  );
}
