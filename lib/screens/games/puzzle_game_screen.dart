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
import '../../widgets/puzzle_piece.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late final GameController _controller = GameController(MockData.puzzleQuestions);

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
  final result = GameResultModel(
    levelId: widget.levelId,
    levelTitle: 'Aventura Matemática',
    correctAnswers: _controller.correctAnswers,
    totalQuestions: _controller.questions.length,
    points: _controller.points,
  );

  ProgressController.instance.addChallengeResult(result);

  Navigator.of(context).pushReplacementNamed(
    AppRoutes.gameChest,
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
          Image.asset(AppAssets.forestBackground, fit: BoxFit.cover),
          SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                children: [
                  Row(
  children: [
    IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: AppColors.darkGreen,
      ),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    const SizedBox(width: 20),
    const Text(
      'Nivel 2',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    const Spacer(),
    const SizedBox(width: 40),
  ],
),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(question.prompt, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.operationText,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 24),
                  DragTarget<int>(
                    onAccept: (data) => _controller.submitAnswer(data),
                    builder: (context, candidate, rejected) {
                      final isHovering = candidate.isNotEmpty;
                      return Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: isHovering
                              ? AppColors.leafGreen.withOpacity(0.3)
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Icon(Icons.add_box_outlined, color: AppColors.primaryGreen, size: 32),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                    GameFeedback(state: _controller.answerState),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: question.options.map((option) {
                      return PuzzlePiece(
                        assetPath: option.assetPath,
                        value: option.value,
                        enabled: !answered,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Continuar aventura',
                    onPressed: _controller.answerState == AnswerState.correct ? _finish : null,
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
