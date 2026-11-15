import 'package:flutter/material.dart';

import '../app_tokens.dart';

// Un recuadro de esquinas rectas con borde grueso, como en los juegos retro.
class PanelPixel extends StatelessWidget {
  const PanelPixel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: colorOscuro,
        border: Border.all(color: colorClaro, width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(6, 6)),
        ],
      ),
      child: child,
    );
  }
}
