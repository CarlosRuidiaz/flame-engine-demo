// Pruebas unitarias de la capa de datos del récord.

import 'package:flutter_test/flutter_test.dart';

import 'package:flame_engine_demo/features/juego/data/datasources/local/memoria_record_source.dart';
import 'package:flame_engine_demo/features/juego/data/repositories/record_repository.dart';

void main() {
  test('el récord empieza en 0', () async {
    final repo = RecordRepository(MemoriaRecordSource());
    expect(await repo.obtenerRecord(), 0);
  });

  test('lo que se guarda es lo que se lee después', () async {
    final repo = RecordRepository(MemoriaRecordSource());
    await repo.guardarRecord(25);
    expect(await repo.obtenerRecord(), 25);
  });
}
