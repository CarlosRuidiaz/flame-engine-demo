import '../i_record_source.dart';

// Guarda el récord en memoria: dura mientras la app siga abierta.
class MemoriaRecordSource implements IRecordSource {
  double _record = 0;

  @override
  Future<double> leerRecord() async => _record;

  @override
  Future<void> escribirRecord(double record) async {
    _record = record;
  }
}
