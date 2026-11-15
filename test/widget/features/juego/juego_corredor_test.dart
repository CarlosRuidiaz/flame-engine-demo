// Pruebas del juego JuegoCorredor usando flame_test.
// Verifican la estructura del mundo y el comportamiento básico
// sin modificar la lógica del juego.

import 'package:flame_test/flame_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flame_engine_demo/features/juego/data/datasources/local/memoria_record_source.dart';
import 'package:flame_engine_demo/features/juego/data/repositories/record_repository.dart';
import 'package:flame_engine_demo/features/juego/ui/viewmodels/partida_controller.dart';
import 'package:flame_engine_demo/features/juego/ui/views/componentes/jugador.dart';
import 'package:flame_engine_demo/features/juego/ui/views/componentes/obstaculos.dart';
import 'package:flame_engine_demo/features/juego/ui/views/componentes/suelo.dart';
import 'package:flame_engine_demo/features/juego/ui/views/juego_corredor.dart';
import 'package:flame_engine_demo/features/juego/ui/views/pagina_juego.dart';

void main() {
  // Instancia de FlameTester para JuegoCorredor. Cada prueba arma el juego
  // con sus capas reales: fuente en memoria, repositorio y controlador,
  // y con los mismos overlays de la app.
  final tester = FlameTester(
    () => JuegoCorredor(
      partida: PartidaController(RecordRepository(MemoriaRecordSource())),
    ),
    createGameWidget: (juego) => GameWidget(
      game: juego,
      overlayBuilderMap: overlaysDelJuego,
      initialActiveOverlays: overlaysIniciales,
    ),
  );

  // Prueba 1: Al cargar, el mundo contiene un Jugador, un Suelo,
  // un ParallaxComponent, y el juego empieza con jugando == false.
  tester.testGameWidget(
    'el mundo contiene Jugador, Suelo y ParallaxComponent al cargar',
    setUp: (juego, _) async {
      // Esperamos a que el juego y todos sus hijos estén completamente listos.
      await juego.ready();
    },
    verify: (juego, _) async {
      final mundo = juego.world;

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
      final mundo = juego.world;

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
      final mundo = juego.world;

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

  // Prueba 4: el controlador y los componentes trabajan juntos. Sin saltar,
  // el primer obstáculo choca con Lola: se pierde, el mundo se congela, se
  // guarda el récord y aparece la pantalla de choque. Reintentar la quita
  // y limpia los obstáculos.
  tester.testGameWidget(
    'al chocar se pierde y reintentar empieza una partida nueva',
    setUp: (juego, _) async {
      await juego.ready();
    },
    verify: (juego, tester) async {
      final mundo = juego.world;
      mundo.partida.empezar();

      // Avanza cuadro a cuadro a 60 Hz, como mucho 6 segundos de juego.
      // Va dentro de runAsync para que las imágenes de los obstáculos
      // se puedan decodificar fuera del reloj falso de la prueba.
      await tester.runAsync(() async {
        for (var i = 0; i < 60 * 6 && !mundo.perdido; i++) {
          juego.update(1 / 60);
          await juego.ready();
        }
      });

      expect(mundo.perdido, isTrue);
      expect(mundo.velocidad, 0);
      expect(mundo.record, greaterThan(0));
      expect(juego.overlays.isActive('perdiste'), isTrue);

      mundo.reiniciar();
      await tester.runAsync(() async {
        juego.update(0); // procesa las bajas pendientes del árbol
        await juego.ready();
      });

      expect(mundo.jugando, isTrue);
      expect(mundo.puntos, 0);
      expect(mundo.children.whereType<Obstaculo>(), isEmpty);
      expect(juego.overlays.isActive('perdiste'), isFalse);
    },
  );
}
