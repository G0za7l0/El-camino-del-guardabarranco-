import 'package:flutter/material.dart';

import '../models/user_model.dart';

class ExplorerCard extends StatelessWidget {
  const ExplorerCard({
    super.key,
    required this.assetPath,
    required this.type,
    required this.selected,
    required this.onTap,
    required this.backgroundColor,
  });

  final String assetPath;
  final ExplorerType type;
  final bool selected;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Tamaño responsive para teléfonos pequeños.
    final double cardWidth =
        (screenWidth * 0.34).clamp(105.0, 135.0).toDouble();

    final double cardHeight = cardWidth * 1.22;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.04 : 0.96,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),

            // No borde blanco.
            border: Border.all(
              color: selected
                  ? backgroundColor
                  : backgroundColor.withOpacity(0.75),
              width: selected ? 2 : 1,
            ),

            // La selección se marca con sombra.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  selected ? 0.35 : 0.12,
                ),
                blurRadius: selected ? 16 : 7,
                spreadRadius: selected ? 2 : 0,
                offset: Offset(
                  0,
                  selected ? 6 : 3,
                ),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Opacity(
            opacity: selected ? 1.0 : 0.82,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
