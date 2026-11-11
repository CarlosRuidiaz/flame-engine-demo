// Demo de la exposición: un gato astronauta que corre y salta obstáculos, en pixel art.
// Cada parte del archivo corresponde a un concepto de la exposición:
// ciclo del juego, componentes, sprites y animaciones, toques, colisiones
// y overlays de Flutter encima del juego.

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Valores del juego
// ---------------------------------------------------------------------------

// Nivel 3 de la demo: si se cambia este valor (por ejemplo a) y guardas,
// Con hot reload el salto se vuelve lento al instante, sin reiniciar el juego.
const double gravedad = 1800; // píxeles por segundo al cuadrado
const double fuerzaSalto = 700; // velocidad inicial del salto
const double velocidadSuelo = 320; // píxeles por segundo

// Cada pixel del dibujo se ve como un cuadro de 3 x 3 en pantalla.
const double escala = 3;

// El juego "finge" una pantalla de 800 x 400 para verse igual
// en el emulador y en Chrome.
const double anchoMundo = 800;
const double altoMundo = 400;
const double alturaSuelo = 352; // coordenada y donde empieza el suelo

// Colores de la interfaz, tomados de la misma paleta de los sprites.
const Color colorOscuro = Color(0xFF120F26); // azul casi negro
const Color colorClaro = Color(0xFFF0EAFF); // lila muy claro
const Color colorAcento = Color(0xFF4FD1E0); // turquesa
const Color colorRosa = Color(0xFFFF7AB6);
const Color colorPolvo = Color(0xFFB9A7E6); // lavanda

// ---------------------------------------------------------------------------
// Punto de entrada: el juego es un widget más dentro de la app de Flutter
// ---------------------------------------------------------------------------

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: colorOscuro,
        body: GameWidget<JuegoCorredor>(
          game: JuegoCorredor(),
          loadingBuilder: (context) => const Center(
            child: CircularProgressIndicator(color: colorAcento),
          ),
          // Los overlays son widgets normales de Flutter dibujados encima del juego.
          overlayBuilderMap: {
            'inicio': (context, game) => const PantallaInicio(),
            'controles': (context, game) => BotonDepuracion(game: game),
            'perdiste': (context, game) => PantallaPerdiste(game: game),
          },
          initialActiveOverlays: const ['inicio', 'controles'],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// El juego: raíz del árbol de componentes y dueño del ciclo del juego
// ---------------------------------------------------------------------------

class JuegoCorredor extends FlameGame<MundoCorredor>
    with HasCollisionDetection {
  JuegoCorredor()
    : super(
        world: MundoCorredor(),
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
  Color backgroundColor() => const Color(0xFF0B0B24);

  // Nivel 2 de la demo: muestra u oculta las cajas de todos los componentes.
  void alternarDepuracion() {
    final activar = !world.debugMode;
    for (final componente in world.descendants(includeSelf: true)) {
      componente.debugMode = activar;
    }
  }
}

// ---------------------------------------------------------------------------
// El mundo: contiene todo lo que se ve y recibe los toques
// ---------------------------------------------------------------------------

class MundoCorredor extends World
    with HasGameReference<JuegoCorredor>, TapCallbacks {
  final Random azar = Random();

  late final ParallaxComponent fondo;
  late final Jugador jugador;
  late final TextComponent textoPuntos;

  double puntos = 0;
  double record = 0;
  double tiempoParaObstaculo = 1.5;
  bool jugando = false; // empieza en la pantalla de inicio
  bool perdido = false;

  // Todo lo que avanza hacia la izquierda usa esta velocidad.
  // Al perder vale 0, así que el mundo se congela sin pausar el motor.
  double get velocidad => perdido ? 0 : velocidadSuelo;

  @override
  Future<void> onLoad() async {
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
      textRenderer: TextPaint(
        style: const TextStyle(
          color: colorClaro,
          fontFamily: 'monospace',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [Shadow(color: colorOscuro, offset: Offset(3, 3))],
        ),
      ),
    );
    add(textoPuntos);
  }

  // Ciclo del juego: Flame llama este método muchas veces por segundo.
  // dt es el tiempo en segundos desde el cuadro anterior.
  @override
  void update(double dt) {
    super.update(dt);
    if (!jugando) return;

    puntos += dt * 10;
    textoPuntos.text = 'PUNTOS ${puntos.floor()}';

    // Cuenta regresiva para crear el siguiente obstáculo.
    tiempoParaObstaculo -= dt;
    if (tiempoParaObstaculo <= 0) {
      add(azar.nextDouble() < 0.6 ? Meteorito() : Cristal());
      tiempoParaObstaculo = 1.1 + azar.nextDouble() * 1.1;
    }
  }

  // Un toque o un clic en cualquier parte del mundo:
  // en la pantalla de inicio empieza el juego, y jugando hace saltar al gato.
  @override
  void onTapDown(TapDownEvent event) {
    if (perdido) return;
    if (!jugando) {
      jugando = true;
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
    jugando = false;
    perdido = true;
    record = max(record, puntos);
    jugador.golpear();
    levantarPolvo(jugador.center, colorRosa, cantidad: 14);
    fondo.parallax!.baseVelocity = Vector2.zero();
    game.overlays.add('perdiste');
  }

  void reiniciar() {
    removeAll(children.whereType<Obstaculo>().toList());
    jugador.reiniciar();
    puntos = 0;
    tiempoParaObstaculo = 1.2;
    perdido = false;
    jugando = true;
    fondo.parallax!.baseVelocity = Vector2(10, 0);
    game.overlays.remove('perdiste');
  }
}

// ---------------------------------------------------------------------------
// El suelo: baldosas que se mueven hacia la izquierda y vuelven a empezar
// ---------------------------------------------------------------------------

class Suelo extends PositionComponent with HasGameReference<JuegoCorredor> {
  Suelo()
    : super(
        position: Vector2(0, alturaSuelo),
        size: Vector2(anchoMundo, altoMundo - alturaSuelo),
      );

  static const double lado = 16 * escala;
  final List<SpriteComponent> _baldosas = [];
  double _desplazamiento = 0;

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('suelo.png');
    final cantidad = (anchoMundo / lado).ceil() + 1;
    for (var i = 0; i < cantidad; i++) {
      final baldosa = SpriteComponent(
        sprite: sprite,
        // 1 pixel de más para que no se vean líneas entre baldosas
        size: Vector2(lado + 1, lado),
        position: Vector2(i * lado, 0),
      );
      _baldosas.add(baldosa);
      add(baldosa);
    }
  }

  // Ciclo del juego: el suelo avanza a la misma velocidad que los obstáculos.
  @override
  void update(double dt) {
    super.update(dt);
    _desplazamiento = (_desplazamiento + game.world.velocidad * dt) % lado;
    for (var i = 0; i < _baldosas.length; i++) {
      _baldosas[i].position.x = i * lado - _desplazamiento;
    }
  }
}

// ---------------------------------------------------------------------------
// El jugador: un componente con varias animaciones, física simple y una hitbox
// ---------------------------------------------------------------------------

enum EstadoJugador { corriendo, saltando, cayendo, golpeado }

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

// ---------------------------------------------------------------------------
// Los obstáculos: un mixin con el movimiento que comparten el meteorito y el cristal
// ---------------------------------------------------------------------------

mixin Obstaculo on PositionComponent, HasGameReference<JuegoCorredor> {
  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.world.velocidad * dt;

    // Componentes: cuando sale de la pantalla se quita del árbol.
    if (position.x < -width) removeFromParent();
  }
}

class Meteorito extends SpriteComponent
    with HasGameReference<JuegoCorredor>, Obstaculo {
  Meteorito()
    : super(
        position: Vector2(anchoMundo, alturaSuelo),
        size: Vector2.all(16 * escala),
        anchor: Anchor.bottomLeft,
      );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('meteorito.png');
    // Pasiva: solo se compara con hitboxes activas (el jugador),
    // no con los demás obstáculos. Así Flame hace menos cálculos.
    add(
      RectangleHitbox(
        position: Vector2.all(escala),
        size: Vector2(14, 15) * escala,
        collisionType: CollisionType.passive,
      ),
    );
  }
}

class Cristal extends SpriteAnimationComponent
    with HasGameReference<JuegoCorredor>, Obstaculo {
  Cristal()
    : super(
        position: Vector2(anchoMundo, alturaSuelo),
        size: Vector2(16, 24) * escala,
        anchor: Anchor.bottomLeft,
      );

  @override
  Future<void> onLoad() async {
    // cristal.png tiene 2 cuadros de 16 x 24: el cristal brilla despacio.
    animation = await SpriteAnimation.load(
      'cristal.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.4,
        textureSize: Vector2(16, 24),
      ),
    );
    add(
      RectangleHitbox(
        position: Vector2(3, 3) * escala,
        size: Vector2(10, 21) * escala,
        collisionType: CollisionType.passive,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlays: widgets de Flutter encima del juego, con estilo pixel art
// ---------------------------------------------------------------------------

// Un recuadro de esquinas rectas con borde grueso, como en los juegos retro.
class PanelPixel extends StatelessWidget {
  const PanelPixel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: colorOscuro,
        border: Border.all(color: colorClaro, width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(6, 6)),
        ],
      ),
      child: child,
    );
  }
}

const TextStyle estiloTitulo = TextStyle(
  color: colorRosa,
  fontFamily: 'monospace',
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: 4,
);

const TextStyle estiloTexto = TextStyle(
  color: colorClaro,
  fontFamily: 'monospace',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
);

class BotonPixel extends StatelessWidget {
  const BotonPixel({super.key, required this.texto, required this.alPresionar});

  final String texto;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: alPresionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorAcento,
        foregroundColor: colorOscuro,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: colorClaro, width: 3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(texto, style: estiloTexto.copyWith(color: colorOscuro)),
    );
  }
}

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
