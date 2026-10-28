import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_text.dart';
import '../models/game_result_model.dart';
import '../widgets/primary_button.dart';

class LevelCompletedScreen extends StatelessWidget {
  const LevelCompletedScreen({
    super.key,
    required this.result,
  });

  final GameResultModel result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 380;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // --------------------------------------------------------
                  // TÍTULO
                  // --------------------------------------------------------
                  Text(
                    '¡${AppText.completed}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --------------------------------------------------------
                  // GUARDABARRANCO
                  // --------------------------------------------------------
                  Image.asset(
                    AppAssets.guardabarrancoHappy,
                    width: isSmall ? 110 : 130,
                  ),

                  const SizedBox(height: 16),

                  // --------------------------------------------------------
                  // MENSAJE
                  // --------------------------------------------------------
                  const Text(
                    AppText.excellentWork,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Continúa tu aventura por Nicaragua para\n'
                    'desbloquear nuevos desafíos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // --------------------------------------------------------
                  // TARJETA DE RESULTADOS
                  // --------------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _statRow(
                          icon: '⭐',
                          title: 'Respuestas correctas',
                          value:
                              '${result.correctAnswers}/${result.totalQuestions}',
                        ),

                        const SizedBox(height: 14),

                        _statRow(
                          icon: '🏅',
                          title: 'Puntos obtenidos',
                          value: '${result.points} pts',
                        ),

                        if (result.badgeEarned != null) ...[
                          const SizedBox(height: 14),
                          _statRow(
                            icon: '🎖',
                            title: 'Insignia obtenida',
                            value: result.badgeEarned!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // --------------------------------------------------------
                  // BOTONES
                  // --------------------------------------------------------
                  if (isSmall) ...[
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: AppText.continueAdventureShort,
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.missions,
                            (route) => false,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: AppText.repeatLevel,
                        color: Colors.white,
                        textColor: AppColors.darkGreen,
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.gameBones,
                            (route) => false,
                            arguments: result.levelId,
                          );
                        },
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: AppText.continueAdventureShort,
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.missions,
                                (route) => false,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: PrimaryButton(
                            label: AppText.repeatLevel,
                            color: Colors.white,
                            textColor: AppColors.darkGreen,
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.gameBones,
                                (route) => false,
                                arguments: result.levelId,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // FILA DE ESTADÍSTICA
  // ----------------------------------------------------------------------
  Widget _statRow({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icono
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
        ),

        const SizedBox(width: 12),

        // Nombre
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Resultado
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}