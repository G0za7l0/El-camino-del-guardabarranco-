/// Una opción de respuesta, ligada a su asset visual oficial
/// (hueso, pieza de rompecabezas, fruta o globo).
class AnswerOption {
  final int value;
  final String assetPath;

  const AnswerOption({required this.value, required this.assetPath});
}

class QuestionModel {
  final String prompt;
  final int operandA;
  final int operandB;
  final List<AnswerOption> options;
  final int correctAnswer;

  const QuestionModel({
    required this.prompt,
    required this.operandA,
    required this.operandB,
    required this.options,
    required this.correctAnswer,
  });

  String get operationText => '$operandA + $operandB = ?';
}
