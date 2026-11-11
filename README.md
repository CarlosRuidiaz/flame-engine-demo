# Lola's Adventure · Flame Engine Demo

Demo de [Flame](https://flame-engine.org/), el motor de juegos 2D construido sobre Flutter, preparada para una exposición.
Lola es una gata astronauta que corre por un planeta en pixel art y tiene que saltar meteoritos y cristales. Cuanto más tiempo sobrevive, más puntos suma.

Todo el juego está en un solo archivo, [`lib/main.dart`](lib/main.dart), y cada parte del código corresponde a un concepto de Flame (ver la tabla más abajo).

## Jugar en línea

👉 **https://carlosruidiaz.github.io/flame-engine-demo/**

Funciona en el navegador del computador y del celular, sin instalar nada.

## Requisitos para ejecutarlo localmente

- [Flutter](https://docs.flutter.dev/get-started/install) estable con **Dart 3.11 o superior** (Flame 1.38.2 lo exige).
  Puedes comprobar tu versión con `flutter --version`.
- Para la versión web: Google Chrome.
- Para Android, Windows o Linux: las herramientas de esa plataforma que pide `flutter doctor`.

## Clonar y ejecutar

```bash
git clone https://github.com/CarlosRuidiaz/flame-engine-demo.git
cd flame-engine-demo
flutter pub get
flutter run
```

`flutter run` te deja elegir el dispositivo. Para abrirlo directamente en el navegador:

```bash
flutter run -d chrome
```

## Controles

| Acción | Cómo |
| --- | --- |
| Empezar la partida | Toque o clic en cualquier parte de la pantalla de inicio |
| Saltar | Toque o clic en cualquier parte del juego |
| Reintentar | Botón **REINTENTAR** al chocar |
| Ver las cajas de colisión | Botón **VER HITBOXES** (arriba a la derecha) |

El botón **VER HITBOXES** activa el modo de depuración de Flame: muestra el contorno de cada componente y de sus hitboxes, útil para explicar las colisiones.

## Qué concepto de Flame ilustra cada parte del código

| Concepto | Dónde está en `lib/main.dart` | Qué muestra |
| --- | --- | --- |
| **Ciclo del juego** (game loop) | `update(double dt)` en `MundoCorredor`, `Suelo`, `Jugador` y el mixin `Obstaculo` | Flame llama `update` en cada cuadro; `dt` es el tiempo desde el cuadro anterior. Multiplicar por `dt` hace que el juego vaya igual a 60 Hz que a 120 Hz. La gravedad del salto es física simple sobre este ciclo. |
| **Componentes** | `JuegoCorredor` (`FlameGame`), `MundoCorredor` (`World`), `SpriteComponent`, `PositionComponent`, `TextComponent` | El juego es un árbol de componentes: se agregan con `add()`, el orden define cómo se dibujan y se quitan con `removeFromParent()` cuando salen de la pantalla. La cámara usa una resolución fija de 800 × 400. |
| **Animaciones con hoja de sprites** | `Jugador` (`SpriteAnimationGroupComponent`) y `Cristal` (`SpriteAnimationComponent`) | `jugador.png` tiene 7 cuadros de 20 × 20: 4 para correr, uno para saltar, uno para caer y uno para el golpe. Cada estado (`EstadoJugador`) usa una animación distinta de la misma hoja. |
| **Parallax** | `game.loadParallaxComponent` en `MundoCorredor.onLoad` | Tres capas (estrellas, nebulosa y rocas) se mueven a distinta velocidad para dar sensación de profundidad. |
| **Partículas** | `levantarPolvo` con `ParticleSystemComponent`, `AcceleratedParticle` y `ComputedParticle` | Polvo al saltar y aterrizar, y una explosión rosa al chocar. Cada partícula tiene velocidad y gravedad, y se encoge al final de su vida. |
| **Toques** (input) | `TapCallbacks` y `onTapDown` en `MundoCorredor` | Un toque o clic empieza la partida o hace saltar a Lola. |
| **Colisiones** | `HasCollisionDetection`, `RectangleHitbox`, `CollisionCallbacks` y `onCollisionStart` en `Jugador` | La hitbox del jugador es más pequeña que el dibujo. Los obstáculos usan `CollisionType.passive` para que Flame haga menos cálculos. |
| **Overlays** | `overlayBuilderMap` del `GameWidget`: `PantallaInicio`, `BotonDepuracion` y `PantallaPerdiste` | Widgets normales de Flutter dibujados encima del juego: la pantalla de inicio, el botón de hitboxes y la pantalla de “¡CHOCASTE!”. |

### Para experimentar

En la parte superior de `lib/main.dart` están las constantes `gravedad`, `fuerzaSalto` y `velocidadSuelo`. Cambia por ejemplo `gravedad` a `600`, guarda, y con *hot reload* verás el salto en cámara lenta sin reiniciar el juego.

## Estructura

```
lib/main.dart         Todo el código del juego
assets/images/        Las 8 imágenes en pixel art (sprites, fondo y parallax)
.github/workflows/    Publicación automática en GitHub Pages
```

## Publicación

Cada push a `main` ejecuta el workflow [`deploy.yml`](.github/workflows/deploy.yml), que compila la versión web con
`flutter build web --release --base-href /flame-engine-demo/` y la publica en GitHub Pages.

## Integrantes

- [CarlosRuidiaz](https://github.com/CarlosRuidiaz)
- [Claudia Elias](https://github.com/ClaudiaElias)
