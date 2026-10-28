import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../data/mock_data.dart';
import '../../models/game_result_model.dart';
import '../../widgets/fruit_option.dart';
import '../../widgets/game_feedback.dart';
import '../../widgets/primary_button.dart';

class MonsterGameScreen extends StatefulWidget {
  const MonsterGameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<MonsterGameScreen> createState() => _MonsterGameScreenState();
}

class _MonsterGameScreenState extends State<MonsterGameScreen> {
  late final GameController _controller = GameController(MockData.monsterQuestions);

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
    AppRoutes.gameBalloons,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.darkGreen),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      const Text('Nivel 2', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 16),
                  Text(
                    question.operationText,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(AppAssets.monster, width: 160),
                  const Spacer(),
                  GameFeedback(state: _controller.answerState),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: question.options.map((option) {
                      return FruitOption(
                        assetPath: option.assetPath,
                        enabled: !answered,
                        onTap: () => _controller.submitAnswer(option.value),
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
