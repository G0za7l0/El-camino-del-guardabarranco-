import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../data/mock_data.dart';
import '../../models/game_result_model.dart';
import '../../widgets/game_feedback.dart';
import '../../widgets/primary_button.dart';

class ChestGameScreen extends StatefulWidget {
  const ChestGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<ChestGameScreen> createState() => _ChestGameScreenState();
}

class _ChestGameScreenState extends State<ChestGameScreen> {
  late final GameController _controller = GameController(
    MockData.chestQuestions,
  );

  bool _chestOpened = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_controller.correctAnswers == _controller.questions.length) {
      setState(() {
        _chestOpened = true;
      });
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    final result = GameResultModel(
      levelId: widget.levelId,
      levelTitle: 'Aventura Matemática',
      correctAnswers: _controller.correctAnswers,
      totalQuestions: _controller.questions.length,
      points: _controller.points,
    );

    ProgressController.instance.addChallengeResult(result);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.gameMonster,
      arguments: widget.levelId,
    );
  }

  void _onAnswer(int value) {
    final isCorrect = _controller.submitAnswer(value);

    if (isCorrect && !_controller.isLastQuestion) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.nextQuestion();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _controller.currentQuestion;
    final answered = _controller.answerState != AnswerState.pending;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.forestBackground,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: Column(
                children: [
                  // ---------------------------------------------------
                  // Encabezado
                  // ---------------------------------------------------
                  Row(
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // ---------------------------------------------------
                  // Instrucción
                  // ---------------------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Resuelve 5 sumas para abrir el cofre',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ---------------------------------------------------
                  // Zona central del juego
                  // ---------------------------------------------------
                  Expanded(
                    child: Column(
                      children: [
                        if (!_chestOpened) ...[
                          const SizedBox(height: 4),

                          Text(
                            question.operationText,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],

                        // El cofre ocupa más espacio y queda centrado.
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              _chestOpened
                                  ? AppAssets.chestOpen
                                  : AppAssets.chestClosed,
                              width: 230,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // Indicadores de las 5 sumas
                        // ------------------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _controller.questions.length,
                            (i) {
                              final done =
                                  i < _controller.correctAnswers;

                              return AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? AppColors.correctGreen
                                      : Colors.white,
                                  border: Border.all(
                                    color: AppColors.primaryGreen,
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // Preguntas / resultado final
                        // ------------------------------------------------
                        if (!_chestOpened) ...[
                          GameFeedback(
                            state: _controller.answerState,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: question.options.map((option) {
                              return _NumberChip(
                                value: option.value,
                                enabled: !answered,
                                onTap: () =>
                                    _onAnswer(option.value),
                              );
                            }).toList(),
                          ),
                        ] else
                          const Text(
                            '¡COFRE ABIERTO!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------------------------------------------------
                  // Botón
                  // ---------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Continuar aventura',
                      onPressed: _chestOpened ? _finish : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final int value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.sunYellow,
        child: Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}