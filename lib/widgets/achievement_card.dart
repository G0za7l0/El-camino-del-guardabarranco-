import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.achievement});

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final locked = !achievement.unlocked;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: locked ? AppColors.lockedGrey.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: locked
            ? null
            : const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
      ),
      child: Column(
        children: [
          Icon(
            locked ? Icons.lock_rounded : Icons.emoji_events_rounded,
            size: 32,
            color: locked ? AppColors.lockedGrey : AppColors.sunYellow,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: locked ? AppColors.textGrey : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
