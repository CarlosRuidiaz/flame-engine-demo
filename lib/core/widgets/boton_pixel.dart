import 'package:flutter/material.dart';

import '../app_tokens.dart';

class BotonPixel extends StatelessWidget {
  const BotonPixel({super.key, required this.texto, required this.alPresionar});

  final String texto;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: alPresionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorAcento,
        foregroundColor: colorOscuro,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: colorClaro, width: 3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(texto, style: estiloTexto.copyWith(color: colorOscuro)),
    );
  }
}
