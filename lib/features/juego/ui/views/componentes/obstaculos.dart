import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../../../core/ajustes_juego.dart';
import '../juego_corredor.dart';

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
