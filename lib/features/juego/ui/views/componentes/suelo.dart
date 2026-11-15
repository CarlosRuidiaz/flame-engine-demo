import 'package:flame/components.dart';

import '../../../../../core/ajustes_juego.dart';
import '../juego_corredor.dart';

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
