import 'package:flutter/material.dart';

/// Pieza de rompecabezas arrastrable de verdad (Draggable real, no un
/// botón disfrazado). Se suelta sobre el [DragTarget] de la pantalla
/// del juego.
class PuzzlePiece extends StatelessWidget {
  const PuzzlePiece({
    super.key,
    required this.assetPath,
    required this.value,
    this.width = 90,
    this.enabled = true,
  });

  final String assetPath;
  final int value;
  final double width;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(assetPath, width: width);

    if (!enabled) {
      return Opacity(opacity: 0.4, child: image);
    }

    return Draggable<int>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(assetPath, width: width * 1.15),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: image),
      child: image,
    );
  }
}
