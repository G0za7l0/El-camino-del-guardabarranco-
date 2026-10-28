class GameResultModel {
  final int levelId;
  final String levelTitle;
  final int correctAnswers;
  final int totalQuestions;
  final int points;
  final String? badgeEarned;

  const GameResultModel({
    required this.levelId,
    required this.levelTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.points,
    this.badgeEarned,
  });

  bool get passed => correctAnswers > 0;
}
