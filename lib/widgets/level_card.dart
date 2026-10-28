import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/level_model.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.onTap,
  });

  final LevelModel level;
  final VoidCallback onTap;

  IconData get _subjectIcon =>
      level.subject == MissionSubject.matematica ? Icons.grid_view_rounded : Icons.translate_rounded;

  @override
  Widget build(BuildContext context) {
    final isMath = level.subject == MissionSubject.matematica;
    final locked = !level.unlocked;
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_subjectIcon, color: AppColors.primaryGreen),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${level.rewardXp}',
                    style: const TextStyle(
                      color: AppColors.pitahayaOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              level.description,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level.title,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (level.completed)
              Row(
                children: const [
                  Icon(Icons.check_circle, color: AppColors.correctGreen, size: 18),
                  SizedBox(width: 6),
                  Text('Completado', style: TextStyle(color: AppColors.correctGreen, fontWeight: FontWeight.bold)),
                ],
              )
            else
              SizedBox(
  width: double.infinity,
child: ElevatedButton(
  onPressed: level.unlocked ? onTap : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.grey.shade200,
    disabledForegroundColor: Colors.grey.shade500,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  child: Text(
    !level.unlocked
        ? 'BLOQUEADO'
        : 'CONTINUAR AVENTURA',
  ),
),
),
          ],
        ),
      ),
    );
  }
}
