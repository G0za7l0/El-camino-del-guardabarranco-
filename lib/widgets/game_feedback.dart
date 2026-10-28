import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../controllers/game_controller.dart';

/// Overlay de feedback (✔ / ✘) que se muestra brevemente tras responder.
class GameFeedback extends StatelessWidget {
  const GameFeedback({super.key, required this.state});

  final AnswerState state;

  @override
  Widget build(BuildContext context) {
    if (state == AnswerState.pending) return const SizedBox.shrink();

    final isCorrect = state == AnswerState.correct;
    final color = isCorrect ? AppColors.correctGreen : AppColors.incorrectRed;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final label = isCorrect ? '¡Correcto!' : 'Intenta de nuevo';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
