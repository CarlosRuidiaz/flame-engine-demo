// Pruebas unitarias del PartidaController: las reglas de la partida
// se prueban en Dart puro, sin Flame ni pantalla.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:flame_engine_demo/core/ajustes_juego.dart';
import 'package:flame_engine_demo/features/juego/domain/models/tipo_obstaculo.dart';
import 'package:flame_engine_demo/features/juego/domain/repositories/i_record_repository.dart';
import 'package:flame_engine_demo/features/juego/ui/viewmodels/partida_controller.dart';

// Doble del repositorio: guarda el récord en memoria y cuenta las escrituras.
class RecordRepositoryFalso implements IRecordRepository {
  RecordRepositoryFalso([this.record = 0]);

  double record;
  int guardados = 0;

  @override
  Future<double> obtenerRecord() async => record;

  @override
  Future<void> guardarRecord(double record) async {
    this.record = record;
    guardados++;
  }
}

// Azar con valores fijos, para saber qué obstáculo sale.
class AzarFijo implements Random {
  AzarFijo(this.valores);

  final List<double> valores;
  int _i = 0;

  @override
  double nextDouble() => valores[_i++ % valores.length];

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}

void main() {
  late RecordRepositoryFalso repo;
  late PartidaController partida;

  setUp(() {
    repo = RecordRepositoryFalso();
    partida = PartidaController(repo, azar: AzarFijo([0.5]));
  });

  test('empieza en la pantalla de inicio, sin puntos', () {
    expect(partida.jugando, isFalse);
    expect(partida.perdido, isFalse);
    expect(partida.puntos, 0);
    expect(partida.velocidad, velocidadSuelo);
  });

  test('sin jugar, avanzar no suma puntos ni crea obstáculos', () {
    expect(partida.avanzar(5), isNull);
    expect(partida.puntos, 0);
  });

  test('jugando suma 10 puntos por segundo', () {
    partida.empezar();
    partida.avanzar(1);
    expect(partida.puntos, closeTo(10, 0.0001));
  });

  test('crea un obstáculo cuando termina la cuenta regresiva', () {
    partida.empezar();
    expect(partida.avanzar(1), isNull); // quedan 0,5 s de los 1,5 iniciales
    expect(partida.avanzar(0.5), TipoObstaculo.meteorito); // 0,5 < 0,6
    // La siguiente cuenta va de 1,1 a 2,2 s; con azar 0,5 es 1,65 s.
    expect(partida.tiempoParaObstaculo, closeTo(1.65, 0.0001));
  });

  test('con azar mayor o igual a 0,6 sale un cristal', () {
    partida = PartidaController(repo, azar: AzarFijo([0.8]));
    partida.empezar();
    expect(partida.avanzar(1.5), TipoObstaculo.cristal);
  });

  test('al perder se congela el mundo y se guarda el récord', () {
    partida.empezar();
    partida.avanzar(1.2); // 12 puntos
    partida.perder();

    expect(partida.jugando, isFalse);
    expect(partida.perdido, isTrue);
    expect(partida.velocidad, 0);
    expect(partida.record, closeTo(12, 0.0001));
    expect(repo.record, closeTo(12, 0.0001));
    expect(repo.guardados, 1);
  });

  test('el récord no baja si la partida nueva hace menos puntos', () {
    partida.empezar();
    partida.avanzar(1.2);
    partida.perder();
    partida.reiniciar();
    partida.avanzar(0.3);
    partida.perder();

    expect(partida.record, closeTo(12, 0.0001));
  });

  test('reiniciar vuelve a cero los puntos y sigue jugando', () {
    partida.empezar();
    partida.avanzar(1);
    partida.perder();
    partida.reiniciar();

    expect(partida.puntos, 0);
    expect(partida.jugando, isTrue);
    expect(partida.perdido, isFalse);
    expect(partida.tiempoParaObstaculo, 1.2);
  });

  test('cargarRecord trae el récord guardado en el repositorio', () async {
    partida = PartidaController(RecordRepositoryFalso(40));
    await partida.cargarRecord();
    expect(partida.record, 40);
  });
}
