import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/ajustes_juego.dart';
import '../../domain/models/tipo_obstaculo.dart';
import '../../domain/repositories/i_record_repository.dart';

// Reglas de la partida: puntos, récord, cuándo aparece un obstáculo y
// si se está jugando. No depende de Flame, así que se prueba sin pantalla.
class PartidaController extends GetxController {
  PartidaController(this.recordRepo, {Random? azar}) : azar = azar ?? Random();

  final IRecordRepository recordRepo;
  final Random azar;

  double puntos = 0;
  double record = 0;
  double tiempoParaObstaculo = 1.5;
  bool jugando = false; // empieza en la pantalla de inicio
  bool perdido = false;

  // Todo lo que avanza hacia la izquierda usa esta velocidad.
  // Al perder vale 0, así que el mundo se congela sin pausar el motor.
  double get velocidad => perdido ? 0 : velocidadSuelo;

  Future<void> cargarRecord() async {
    record = await recordRepo.obtenerRecord();
  }

  // Se llama en cada cuadro del ciclo del juego. Suma puntos, lleva la
  // cuenta regresiva y devuelve el obstáculo que hay que crear, si toca uno.
  TipoObstaculo? avanzar(double dt) {
    if (!jugando) return null;

    puntos += dt * 10;

    tiempoParaObstaculo -= dt;
    if (tiempoParaObstaculo <= 0) {
      final tipo = azar.nextDouble() < 0.6
          ? TipoObstaculo.meteorito
          : TipoObstaculo.cristal;
      tiempoParaObstaculo = 1.1 + azar.nextDouble() * 1.1;
      return tipo;
    }
    return null;
  }

  void empezar() {
    jugando = true;
  }

  void perder() {
    jugando = false;
    perdido = true;
    record = max(record, puntos);
    unawaited(recordRepo.guardarRecord(record));
  }

  void reiniciar() {
    puntos = 0;
    tiempoParaObstaculo = 1.2;
    perdido = false;
    jugando = true;
  }
}
