import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_text.dart';
import '../controllers/progress_controller.dart';
import '../models/level_model.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/level_card.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

 void _openLevel(BuildContext context, LevelModel level) {
  if (!level.unlocked) return;
  if (level.challenges.isEmpty) return;

  final game = level.challenges.first;

    String? route;

    switch (game) {
      case GameType.bones:
        route = AppRoutes.gameBones;
        break;

      case GameType.puzzle:
        route = AppRoutes.gamePuzzle;
        break;

      case GameType.chest:
        route = AppRoutes.gameChest;
        break;

      case GameType.monster:
        route = AppRoutes.gameMonster;
        break;

      case GameType.balloons:
        route = AppRoutes.gameBalloons;
        break;

      case GameType.bridge:
        route = AppRoutes.gameBridge;
        break;

              case GameType.englishListen:
        route = AppRoutes.gameEnglishListen;
        break;

      case GameType.englishWord:
        route = AppRoutes.gameEnglishWord;
        break;

      case GameType.englishWater:
        route = AppRoutes.gameEnglishWater;
        break;

      case GameType.englishMatch:
        route = AppRoutes.gameEnglishMatch;
        break;
    }

    if (route == null) return;

    Navigator.of(context).pushNamed(
      route,
      arguments: level.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressController.instance;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: AppRoutes.missions,
      ),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.streakDays}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Nivel ${progress.currentLevel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        AppAssets.guardabarrancoHappy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.leafGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                          AppAssets.guardabarrancoHappy,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Tú puedes, aventurero!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  AppText.todaysMissions,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 12),

                ...progress.levels.map(
                  (level) => LevelCard(
                    level: level,
                    onTap: () => _openLevel(context, level),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}