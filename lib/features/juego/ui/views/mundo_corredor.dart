import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../../../core/ajustes_juego.dart';
import '../../../../core/app_tokens.dart';
import '../../domain/models/tipo_obstaculo.dart';
import '../viewmodels/partida_controller.dart';
import 'componentes/jugador.dart';
import 'componentes/obstaculos.dart';
import 'componentes/suelo.dart';
import 'juego_corredor.dart';

// ---------------------------------------------------------------------------
// El mundo: contiene todo lo que se ve y recibe los toques.
// Las reglas de la partida las decide el PartidaController.
// ---------------------------------------------------------------------------

class MundoCorredor extends World
    with HasGameReference<JuegoCorredor>, TapCallbacks {
  MundoCorredor(this.partida);

  final PartidaController partida;
  final Random azar = Random();

  late final ParallaxComponent fondo;
  late final Jugador jugador;
  late final TextComponent textoPuntos;

  // Atajos al estado de la partida, para los componentes y los overlays.
  double get puntos => partida.puntos;
  double get record => partida.record;
  bool get jugando => partida.jugando;
  bool get perdido => partida.perdido;
  double get velocidad => partida.velocidad;

  @override
  Future<void> onLoad() async {
    await partida.cargarRecord();

    // Componentes: el mundo se arma agregando piezas al árbol.
    // El orden en que se agregan es el orden en que se dibujan.

    // 1. El espacio del fondo es una sola imagen que no se mueve.
    add(
      SpriteComponent(
        sprite: await Sprite.load('espacio.png'),
        size: Vector2(anchoMundo, altoMundo),
      ),
    );

    // 2. Parallax: tres capas que se mueven a distinta velocidad.
    //    Las estrellas van más lento y las rocas más rápido, lo que da profundidad.
    fondo = await game.loadParallaxComponent(
      [
        ParallaxImageData('estrellas.png'),
        ParallaxImageData('nebulosa.png'),
        ParallaxImageData('rocas.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(2, 1),
      size: Vector2(anchoMundo, altoMundo),
      filterQuality: FilterQuality.none, // pixeles nítidos, sin difuminar
    );
    add(fondo);

    // 3. El suelo, el jugador y el texto de puntos.
    add(Suelo());

    jugador = Jugador();
    add(jugador);

    textoPuntos = TextComponent(
      text: 'PUNTOS 0',
      position: Vector2(20, 16),
      priority: 2,
      textRenderer: TextPaint(style: estiloPuntos),
    );
    add(textoPuntos);
  }

  // Ciclo del juego: Flame llama este método muchas veces por segundo.
  // dt es el tiempo en segundos desde el cuadro anterior.
  @override
  void update(double dt) {
    super.update(dt);
    if (!jugando) return;

    // El controlador suma los puntos y dice cuándo crear el siguiente obstáculo.
    final obstaculo = partida.avanzar(dt);
    textoPuntos.text = 'PUNTOS ${puntos.floor()}';
    if (obstaculo != null) {
      add(obstaculo == TipoObstaculo.meteorito ? Meteorito() : Cristal());
    }
  }

  // Un toque o un clic en cualquier parte del mundo:
  // en la pantalla de inicio empieza el juego, y jugando hace saltar al gato.
  @override
  void onTapDown(TapDownEvent event) {
    if (perdido) return;
    if (!jugando) {
      partida.empezar();
      game.overlays.remove('inicio');
      return;
    }
    jugador.saltar();
  }

  // Partículas: cuadritos que salen disparados y caen con gravedad.
  void levantarPolvo(Vector2 lugar, Color color, {int cantidad = 8}) {
    final pintura = Paint()..color = color;
    add(
      ParticleSystemComponent(
        position: lugar,
        priority: 1,
        particle: Particle.generate(
          count: cantidad,
          lifespan: 0.45,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              azar.nextDouble() * 160 - 80,
              -40 - azar.nextDouble() * 140,
            ),
            acceleration: Vector2(0, 500),
            child: ComputedParticle(
              renderer: (canvas, particula) {
                // Cada partícula se encoge a medida que se acaba su vida.
                final lado = escala * 2 * (1 - particula.progress) + 1;
                canvas.drawRect(Rect.fromLTWH(0, 0, lado, lado), pintura);
              },
            ),
          ),
        ),
      ),
    );
  }

  void perder() {
    partida.perder();
    jugador.golpear();
    levantarPolvo(jugador.center, colorRosa, cantidad: 14);
    fondo.parallax!.baseVelocity = Vector2.zero();
    game.overlays.add('perdiste');
  }

  void reiniciar() {
    removeAll(children.whereType<Obstaculo>().toList());
    jugador.reiniciar();
    partida.reiniciar();
    fondo.parallax!.baseVelocity = Vector2(10, 0);
    game.overlays.remove('perdiste');
  }
}
