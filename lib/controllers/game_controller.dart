import 'package:flutter/foundation.dart';

import '../models/question_model.dart';

enum AnswerState { pending, correct, incorrect }

/// Controla el estado de una sesión de juego: pregunta actual,
/// respuestas correctas/incorrectas, puntos e intentos.
/// Se instancia UNA vez por pantalla de juego (no es singleton).
class GameController extends ChangeNotifier {
  GameController(this.questions);

  final List<QuestionModel> questions;

  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int incorrectAttempts = 0;
  int points = 0;
  AnswerState answerState = AnswerState.pending;
  int? selectedValue;

  QuestionModel get currentQuestion => questions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFinished =>
      currentQuestionIndex >= questions.length && questions.isNotEmpty;
  double get progress =>
      questions.isEmpty ? 0 : currentQuestionIndex / questions.length;

  /// Registra la selección del usuario. Devuelve `true` si fue correcta.
bool submitAnswer(int value) {
  selectedValue = value;
  final isCorrect = value == currentQuestion.correctAnswer;

  // ==================================================
  // API CONNECTION POINT
  // SCREEN: GAME (dinámico según mini-juego)
  // ACTION: REGISTER ANSWER
  // ==================================================
  //
  // FUTURE ENDPOINT:
  // POST /api/game/answer
  //
  // DATA:
  // - userId
  // - levelId
  // - questionId
  // - answer: value
  // - isCorrect
  // - points
  //
  // TODO:
  // Replace local logic with API call.
  // ==================================================

  if (isCorrect) {
    correctAnswers += 1;
    points += 20;
    answerState = AnswerState.correct;
  } else {
    incorrectAttempts += 1;

    // Mostramos "Intenta de nuevo".
    answerState = AnswerState.incorrect;
  }

  notifyListeners();

  // Si es incorrecta, permitimos volver a seleccionar.
  if (!isCorrect) {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (answerState == AnswerState.incorrect) {
        answerState = AnswerState.pending;
        selectedValue = null;
        notifyListeners();
      }
    });
  }

  return isCorrect;
}
  /// Avanza a la siguiente pregunta (o marca el juego como terminado).
  void nextQuestion() {
    answerState = AnswerState.pending;
    selectedValue = null;
    currentQuestionIndex += 1;
    notifyListeners();
  }

  /// Reinicia por completo la sesión (botón "Repetir nivel").
  void reset() {
    currentQuestionIndex = 0;
    correctAnswers = 0;
    incorrectAttempts = 0;
    points = 0;
    answerState = AnswerState.pending;
    selectedValue = null;
    notifyListeners();
  }
}
