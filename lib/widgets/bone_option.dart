import 'package:flutter/material.dart';

/// Opción tocable con forma de hueso (usa el asset oficial bone_XX).
/// Reutilizado también para las opciones de fruta del juego del
/// monstruo (misma mecánica de "tocar para responder").
class BoneOption extends StatelessWidget {
  const BoneOption({
    super.key,
    required this.assetPath,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.width = 100,
  });

  final String assetPath;
  final int value;
  final VoidCallback onTap;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedScale(
        scale: enabled ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 150),
        child: Image.asset(assetPath, width: width),
      ),
    );
  }
}
