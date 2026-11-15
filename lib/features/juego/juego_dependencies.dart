import 'package:get/get.dart';

import 'data/datasources/i_record_source.dart';
import 'data/datasources/local/memoria_record_source.dart';
import 'data/repositories/record_repository.dart';
import 'domain/repositories/i_record_repository.dart';
import 'ui/viewmodels/partida_controller.dart';

// Registra las piezas del juego, de la capa de datos hacia la interfaz.
// La fuente se puede inyectar, por ejemplo en las pruebas.
void registerJuego({IRecordSource? source}) {
  Get.lazyPut<IRecordSource>(
    () => source ?? MemoriaRecordSource(),
    fenix: true,
  );

  Get.lazyPut<IRecordRepository>(
    () => RecordRepository(Get.find<IRecordSource>()),
    fenix: true,
  );

  Get.lazyPut(
    () => PartidaController(Get.find<IRecordRepository>()),
    fenix: true,
  );
}
