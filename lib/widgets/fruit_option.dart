import 'package:flutter/material.dart';

/// Opción tocable con forma de plato de comida (asset oficial
/// apple_13 / banana_14 / strawberry_15) para el juego del monstruo.
class FruitOption extends StatelessWidget {
  const FruitOption({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.enabled = true,
    this.width = 90,
  });

  final String assetPath;
  final VoidCallback onTap;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Image.asset(assetPath, width: width),
    );
  }
}
