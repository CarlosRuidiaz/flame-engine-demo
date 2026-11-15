import '../../domain/repositories/i_record_repository.dart';
import '../datasources/i_record_source.dart';

class RecordRepository implements IRecordRepository {
  RecordRepository(this.source);

  final IRecordSource source;

  @override
  Future<double> obtenerRecord() => source.leerRecord();

  @override
  Future<void> guardarRecord(double record) => source.escribirRecord(record);
}
