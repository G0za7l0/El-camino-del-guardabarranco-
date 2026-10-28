import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../data/mock_data.dart';
import '../../models/game_result_model.dart';
import '../../widgets/bone_option.dart';
import '../../widgets/game_feedback.dart';
import '../../widgets/primary_button.dart';

class BonesGameScreen extends StatefulWidget {
  const BonesGameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<BonesGameScreen> createState() => _BonesGameScreenState();
}

class _BonesGameScreenState extends State<BonesGameScreen> {
  late final GameController _controller =
      GameController(MockData.bonesQuestions);

  @override
  void initState() {
    super.initState();

    ProgressController.instance.startLevelSession(widget.levelId);

    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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
      AppRoutes.gamePuzzle,
      arguments: widget.levelId,
    );
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
                  // Encabezado
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

                  // Instrucción
                  _MessageBubble(text: question.prompt),

                  const SizedBox(height: 14),

                  // Operación
                  Text(
                    question.operationText,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  // Área central del personaje
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        AppAssets.dog,
                        width: 205,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Feedback
                  GameFeedback(
                    state: _controller.answerState,
                  ),

                  const SizedBox(height: 10),

                  // Respuestas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: question.options.map((option) {
                      return BoneOption(
                        assetPath: option.assetPath,
                        value: option.value,
                        enabled: !answered,
                        onTap: () =>
                            _controller.submitAnswer(option.value),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Continuar aventura',
                      onPressed:
                          _controller.answerState == AnswerState.correct
                              ? _finish
                              : null,
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textDark,
        ),
      ),
    );
  }
}