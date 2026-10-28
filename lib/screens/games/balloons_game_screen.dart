import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/game_controller.dart';
import '../../data/mock_data.dart';
import '../../widgets/balloon_option.dart';
import '../../widgets/game_feedback.dart';
import '../../widgets/primary_button.dart';

class BalloonsGameScreen extends StatefulWidget {
  const BalloonsGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<BalloonsGameScreen> createState() => _BalloonsGameScreenState();
}

class _BalloonsGameScreenState extends State<BalloonsGameScreen> {
  late final GameController _controller = GameController(
    MockData.balloonsQuestions,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_controller.answerState != AnswerState.correct) return;

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.gameBridge,
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
                  Container(
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
                      question.prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

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

                  // Área central para los globos
                  Expanded(
                    child: Center(
                      child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: question.options.map((option) {
    final isWideAsset = option.value == 12;

    return SizedBox(
      width: 105,
      height: 145,
      child: Transform.scale(
        scale: isWideAsset ? 1.18 : 1.0,
        child: BalloonOption(
          key: ValueKey(
            '${_controller.currentQuestionIndex}-${option.value}',
          ),
          assetPath: option.assetPath,
          enabled: !answered,
          onTap: () => _controller.submitAnswer(option.value),
        ),
      ),
    );
  }).toList(),
),
                    ),
                  ),

                  // Feedback
                  GameFeedback(
                    state: _controller.answerState,
                  ),

                  const SizedBox(height: 10),

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