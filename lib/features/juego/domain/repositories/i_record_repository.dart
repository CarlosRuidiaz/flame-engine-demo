// Contrato para leer y guardar el récord. El controlador solo conoce
// esta interfaz, no sabe de dónde viene ni dónde se guarda el valor.
abstract class IRecordRepository {
  Future<double> obtenerRecord();
  Future<void> guardarRecord(double record);
}
