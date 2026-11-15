import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../../../core/ajustes_juego.dart';
import '../../../../../core/app_tokens.dart';
import '../../../domain/models/estado_jugador.dart';
import '../juego_corredor.dart';
import 'obstaculos.dart';

// ---------------------------------------------------------------------------
// El jugador: un componente con varias animaciones, física simple y una hitbox
// ---------------------------------------------------------------------------

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with CollisionCallbacks, HasGameReference<JuegoCorredor> {
  Jugador()
    : super(
        position: Vector2(100, alturaSuelo),
        size: Vector2.all(20 * escala),
        anchor: Anchor.bottomLeft, // la posición marca los pies
        priority: 1,
      );

  double velocidadY = 0;

  bool get enElSuelo => position.y >= alturaSuelo;

  // Cada animación toma algunos cuadros de la misma hoja de sprites.
  // jugador.png tiene 7 cuadros de 20 x 20: 4 de correr, saltar, caer y golpe.
  Future<SpriteAnimation> _animacion(int primerCuadro, int cuadros) {
    return SpriteAnimation.load(
      'jugador.png',
      SpriteAnimationData.sequenced(
        amount: cuadros,
        stepTime: 0.1,
        textureSize: Vector2.all(20),
        texturePosition: Vector2(primerCuadro * 20.0, 0),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    animations = {
      EstadoJugador.corriendo: await _animacion(0, 4),
      EstadoJugador.saltando: await _animacion(4, 1),
      EstadoJugador.cayendo: await _animacion(5, 1),
      EstadoJugador.golpeado: await _animacion(6, 1),
    };
    current = EstadoJugador.corriendo;

    // Colisiones: la hitbox es más pequeña que el dibujo,
    // para que un choque solo cuente si de verdad toca al gato.
    // La cola y la mochila quedan por fuera.
    add(
      RectangleHitbox(
        position: Vector2(7, 3) * escala,
        size: Vector2(9, 14) * escala,
      ),
    );
  }

  void saltar() {
    if (!enElSuelo || current == EstadoJugador.golpeado) return;
    velocidadY = -fuerzaSalto;
    game.world.levantarPolvo(position + Vector2(width / 2, 0), colorPolvo);
  }

  void golpear() {
    current = EstadoJugador.golpeado;
  }

  void reiniciar() {
    position.y = alturaSuelo;
    velocidadY = 0;
    current = EstadoJugador.corriendo;
  }

  // Ciclo del juego: la gravedad cambia la velocidad y la velocidad cambia
  // la posición. Multiplicar por dt hace que el salto dure lo mismo
  // en una pantalla de 60 Hz que en una de 120 Hz.
  @override
  void update(double dt) {
    super.update(dt); // avanza la animación actual
    if (current == EstadoJugador.golpeado) return;

    final estabaEnElAire = !enElSuelo;
    velocidadY += gravedad * dt;
    position.y += velocidadY * dt;

    if (position.y >= alturaSuelo) {
      position.y = alturaSuelo;
      velocidadY = 0;
      if (estabaEnElAire) {
        game.world.levantarPolvo(position + Vector2(width / 2, 0), colorPolvo);
      }
    }

    // La animación depende del estado: en el suelo corre,
    // subiendo usa el cuadro de salto y bajando el de caída.
    if (enElSuelo) {
      current = EstadoJugador.corriendo;
    } else {
      current = velocidadY < 0 ? EstadoJugador.saltando : EstadoJugador.cayendo;
    }
  }

  // Colisiones: Flame llama este método cuando empieza un choque.
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstaculo && game.world.jugando) {
      game.world.perder();
    }
  }
}
