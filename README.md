# Lola's Adventure · Flame Engine Demo

Demo de [Flame](https://flame-engine.org/), el motor de juegos 2D construido sobre Flutter, preparada para una exposición.
Lola es una gata astronauta que corre por un planeta en pixel art y tiene que saltar meteoritos y cristales. Cuanto más tiempo sobrevive, más puntos suma.

El código está organizado con arquitectura limpia (ver [Arquitectura](#arquitectura)) y cada parte corresponde a un concepto de Flame (ver la tabla más abajo).

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

Las rutas son relativas a `lib/features/juego/ui/views/`.

| Concepto | Dónde está | Qué muestra |
| --- | --- | --- |
| **Ciclo del juego** (game loop) | `update(double dt)` en `mundo_corredor.dart` y en `componentes/` (`Suelo`, `Jugador` y el mixin `Obstaculo`) | Flame llama `update` en cada cuadro; `dt` es el tiempo desde el cuadro anterior. Multiplicar por `dt` hace que el juego vaya igual a 60 Hz que a 120 Hz. La gravedad del salto es física simple sobre este ciclo. |
| **Componentes** | `JuegoCorredor` (`FlameGame`) en `juego_corredor.dart`, `MundoCorredor` (`World`) en `mundo_corredor.dart`, y `SpriteComponent`, `PositionComponent`, `TextComponent` | El juego es un árbol de componentes: se agregan con `add()`, el orden define cómo se dibujan y se quitan con `removeFromParent()` cuando salen de la pantalla. La cámara usa una resolución fija de 800 × 400. |
| **Animaciones con hoja de sprites** | `componentes/jugador.dart` (`SpriteAnimationGroupComponent`) y `Cristal` en `componentes/obstaculos.dart` (`SpriteAnimationComponent`) | `jugador.png` tiene 7 cuadros de 20 × 20: 4 para correr, uno para saltar, uno para caer y uno para el golpe. Cada estado (`EstadoJugador`, en `domain/models`) usa una animación distinta de la misma hoja. |
| **Parallax** | `game.loadParallaxComponent` en `MundoCorredor.onLoad` | Tres capas (estrellas, nebulosa y rocas) se mueven a distinta velocidad para dar sensación de profundidad. |
| **Partículas** | `levantarPolvo` en `mundo_corredor.dart`, con `ParticleSystemComponent`, `AcceleratedParticle` y `ComputedParticle` | Polvo al saltar y aterrizar, y una explosión rosa al chocar. Cada partícula tiene velocidad y gravedad, y se encoge al final de su vida. |
| **Toques** (input) | `TapCallbacks` y `onTapDown` en `mundo_corredor.dart` | Un toque o clic empieza la partida o hace saltar a Lola. |
| **Colisiones** | `HasCollisionDetection` en `juego_corredor.dart`; `RectangleHitbox`, `CollisionCallbacks` y `onCollisionStart` en `componentes/jugador.dart` | La hitbox del jugador es más pequeña que el dibujo. Los obstáculos usan `CollisionType.passive` para que Flame haga menos cálculos. |
| **Overlays** | `overlayBuilderMap` del `GameWidget` en `pagina_juego.dart`, y los widgets de `overlays/` | Widgets normales de Flutter dibujados encima del juego: la pantalla de inicio, el botón de hitboxes y la pantalla de “¡CHOCASTE!”. |

### Para experimentar

En [`lib/core/ajustes_juego.dart`](lib/core/ajustes_juego.dart) están las constantes `gravedad`, `fuerzaSalto` y `velocidadSuelo`. Cambia por ejemplo `gravedad` a `600`, guarda, y con *hot reload* verás el salto en cámara lenta sin reiniciar el juego.

## Arquitectura

El proyecto sigue la misma arquitectura limpia pragmática de nuestros proyectos anteriores de Flutter: organizado por funcionalidad y partido en tres capas, donde **cada capa solo conoce a la de adentro**.

```
Componentes de Flame  →  Controlador  →  Repositorio  →  Fuente de datos
└────────────── ui/ ──────────────┘   └─ domain/ ─┘   └──── data/ ────┘
```

- **domain/** tiene los modelos (`EstadoJugador`, `TipoObstaculo`) y el contrato `IRecordRepository`. No depende de Flutter ni de Flame.
- **data/** implementa ese contrato: `RecordRepository` usa una fuente `IRecordSource`. Hoy la fuente es `MemoriaRecordSource`, así que el récord dura mientras el juego siga abierto. Para guardarlo en el dispositivo basta con escribir otra fuente y cambiar una línea en `juego_dependencies.dart`, sin tocar el juego.
- **ui/** tiene el `PartidaController`, con las reglas de la partida (puntos, récord, cuándo aparece un obstáculo, si se está jugando o se perdió), y las vistas: el juego de Flame, sus componentes y los overlays de Flutter. Los componentes se encargan de lo que se ve y se mueve; el controlador decide las reglas.

Como en los proyectos anteriores, no hay un caso de uso por acción: esa lógica vive en el controlador. Las dependencias se registran con GetX en `juego_dependencies.dart` y `main.dart` solo las registra y arranca la app.

```
lib/
├── main.dart                          arranque y registro de dependencias
├── core/
│   ├── ajustes_juego.dart             gravedad, salto, velocidad y tamaño del mundo
│   ├── app_tokens.dart                colores y estilos de texto
│   └── widgets/                       PanelPixel y BotonPixel
└── features/juego/
    ├── juego_dependencies.dart        registro con GetX
    ├── domain/
    │   ├── models/                    EstadoJugador, TipoObstaculo
    │   └── repositories/              IRecordRepository
    ├── data/
    │   ├── datasources/               IRecordSource y MemoriaRecordSource
    │   └── repositories/              RecordRepository
    └── ui/
        ├── viewmodels/                PartidaController
        └── views/
            ├── pagina_juego.dart      GameWidget con los overlays
            ├── juego_corredor.dart    FlameGame y cámara
            ├── mundo_corredor.dart    World: fondo, parallax, partículas y toques
            ├── componentes/           Jugador, Suelo, Meteorito y Cristal
            └── overlays/              inicio, botón de hitboxes y pantalla de choque

test/
├── unit/features/juego/               controlador y repositorio, sin pantalla
└── widget/features/juego/             el juego completo con flame_test
```

Para correr las pruebas:

```bash
flutter test test/unit
```

```bash
flutter test test/widget
```

## Estructura del repositorio

```
lib/                  Código del juego (ver Arquitectura)
test/                 Pruebas unitarias y de widget
assets/images/        Las 8 imágenes en pixel art (sprites, fondo y parallax)
.github/workflows/    Pruebas y publicación automática en GitHub Pages
```

## Publicación

Cada push a `main` ejecuta el workflow [`deploy.yml`](.github/workflows/deploy.yml), que analiza el código, corre las pruebas unitarias y de widget, compila la versión web con
`flutter build web --release --base-href /flame-engine-demo/` y la publica en GitHub Pages.

## Integrantes

- [CarlosRuidiaz](https://github.com/CarlosRuidiaz)
- [Claudia Elias](https://github.com/ClaudiaElias)
