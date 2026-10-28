import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/progress_controller.dart';
import '../../models/game_result_model.dart';
import '../../widgets/primary_button.dart';

class BridgeGameScreen extends StatefulWidget {
  const BridgeGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<BridgeGameScreen> createState() => _BridgeGameScreenState();
}

class _BridgeGameScreenState extends State<BridgeGameScreen> {
  int? _selectedAnswer;
  bool _completed = false;

  final List<_BridgeOption> _options = const [
    _BridgeOption(
      value: 19,
      assetPath: AppAssets.bridge19,
    ),
    _BridgeOption(
      value: 20,
      assetPath: AppAssets.bridge20,
    ),
    _BridgeOption(
      value: 21,
      assetPath: AppAssets.bridge21,
    ),
  ];

  void _checkAnswer(int value) {
    if (_completed) return;

    setState(() {
      _selectedAnswer = value;

      if (value == 21) {
        _completed = true;
      }
    });
  }

  void _finish() {
    if (!_completed) return;

    final result = GameResultModel(
      levelId: widget.levelId,
      levelTitle: 'Aventura Matemática',
      correctAnswers: 1,
      totalQuestions: 1,
      points: 20,
      badgeEarned: 'Maestro de las Sumas',
    );

    ProgressController.instance.completeLevel(result);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.levelCompleted,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final scale = (width / 430).clamp(0.85, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Fondo completo
              Image.asset(
                AppAssets.bridgeBackground,
                fit: BoxFit.cover,
              ),

              SafeArea(
                child: Stack(
                  children: [
                    // --------------------------------------------------
                    // ENCABEZADO
                    // --------------------------------------------------
                    Positioned(
                      top: 2,
                      left: 18,
                      right: 18,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.darkGreen,
                            ),
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                          ),
                          const Spacer(),
                          const Text(
                            'Nivel 1',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // --------------------------------------------------
                    // OPERACIÓN
                    // --------------------------------------------------
                    Positioned(
                      top: 62 * scale,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          AppAssets.bridgeOperation,
                          width: 210 * scale,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // INSTRUCCIÓN
                    // --------------------------------------------------
                    Positioned(
                      top: 158 * scale,
                      left: 20,
                      right: 20,
                      child: const Text(
                        'Arrastra la piedra con la respuesta correcta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // ZONA DEL PUENTE
                    // --------------------------------------------------
                    Positioned(
                      top: height * 0.39,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: DragTarget<int>(
                          onAcceptWithDetails: (details) {
                            _checkAnswer(details.data);
                          },
                          builder: (
                            context,
                            candidateData,
                            rejectedData,
                          ) {
                            final hovering = candidateData.isNotEmpty;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 125 * scale,
                              height: 92 * scale,
                              decoration: BoxDecoration(
                                color: hovering
                                    ? AppColors.primaryGreen.withValues(
                                        alpha: 0.22,
                                      )
                                    : Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _completed
                                      ? AppColors.primaryGreen
                                      : AppColors.darkGreen,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _completed
                                  ? Image.asset(
                                      AppAssets.bridge21,
                                      width: 92 * scale,
                                      height: 72 * scale,
                                      fit: BoxFit.contain,
                                    )
                                  : const Icon(
                                      Icons.add,
                                      size: 42,
                                      color: AppColors.darkGreen,
                                    ),
                            );
                          },
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // PIEDRAS
                    // --------------------------------------------------
                    Positioned(
                      top: height * 0.53,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _options.map((option) {
                          return Draggable<int>(
                            data: option.value,
                            maxSimultaneousDrags: _completed ? 0 : 1,

                            feedback: Material(
                              color: Colors.transparent,
                              child: Image.asset(
                                option.assetPath,
                                width: 82 * scale,
                                height: 72 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),

                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: Image.asset(
                                option.assetPath,
                                width: 82 * scale,
                                height: 72 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),

                            child: Image.asset(
                              option.assetPath,
                              width: 82 * scale,
                              height: 72 * scale,
                              fit: BoxFit.contain,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // --------------------------------------------------
                    // MENSAJE
                    // --------------------------------------------------
                    if (_selectedAnswer != null && !_completed)
                      Positioned(
                        top: height * 0.64,
                        left: 0,
                        right: 0,
                        child: const Text(
                          'Intenta otra vez',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (_completed)
                      Positioned(
                        top: height * 0.64,
                        left: 0,
                        right: 0,
                        child: const Text(
                          '¡Correcto! 🎉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // --------------------------------------------------
                    // BOTÓN
                    // --------------------------------------------------
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: PrimaryButton(
                        label: 'Continuar aventura',
                        onPressed: _completed ? _finish : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BridgeOption {
  final int value;
  final String assetPath;

  const _BridgeOption({
    required this.value,
    required this.assetPath,
  });
}