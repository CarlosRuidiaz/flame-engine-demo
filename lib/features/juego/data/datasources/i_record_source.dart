// Contrato de la fuente de datos del récord. Hoy hay una sola implementación
// en memoria; guardarlo en el dispositivo sería escribir otra fuente.
abstract class IRecordSource {
  Future<double> leerRecord();
  Future<void> escribirRecord(double record);
}
