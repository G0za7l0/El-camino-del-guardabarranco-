import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/achievement_model.dart';
import '../models/game_result_model.dart';
import '../models/level_model.dart';
import '../services/progress_service.dart';

/// Controlador global de progreso.
class ProgressController extends ChangeNotifier {
  ProgressController._internal() {
    _levels = List<LevelModel>.from(MockData.levels);
  }

  static final ProgressController instance =
      ProgressController._internal();

  final ProgressService _service = ProgressService();

  late List<LevelModel> _levels;

  // ------------------------------------------------------------
  // ACUMULADOR DE LA SESIÓN DEL NIVEL
  // ------------------------------------------------------------

  int _sessionLevelId = -1;
  int _sessionCorrectAnswers = 0;
  int _sessionTotalQuestions = 0;
  int _sessionPoints = 0;

  int get sessionCorrectAnswers => _sessionCorrectAnswers;
  int get sessionTotalQuestions => _sessionTotalQuestions;
  int get sessionPoints => _sessionPoints;

  /// Inicia una nueva sesión de nivel.
  void startLevelSession(int levelId) {
    _sessionLevelId = levelId;
    _sessionCorrectAnswers = 0;
    _sessionTotalQuestions = 0;
    _sessionPoints = 0;
  }

  /// Guarda el resultado de un mini-juego sin completar todavía
  /// el nivel completo.
  void addChallengeResult(GameResultModel result) {
    if (_sessionLevelId != result.levelId) {
      startLevelSession(result.levelId);
    }

    _sessionCorrectAnswers += result.correctAnswers;
    _sessionTotalQuestions += result.totalQuestions;
    _sessionPoints += result.points;

    notifyListeners();
  }

  // ------------------------------------------------------------
  // PROGRESO GENERAL
  // ------------------------------------------------------------

  int get experience => _service.experience;
  int get experienceRequired => _service.experienceRequired;
  int get currentLevel => _service.currentLevel;
  int get pitahayas => _service.pitahayas;
  int get streakDays => _service.streakDays;

  double get experienceProgress =>
      (experience / experienceRequired).clamp(0.0, 1.0);

  List<LevelModel> get levels => List.unmodifiable(_levels);

  List<AchievementModel> get achievements => MockData.achievements
      .map(
        (a) => a.copyWith(
          unlocked: _service.unlockedAchievementIds.contains(a.id),
        ),
      )
      .toList();

  LevelModel? levelById(int id) {
    try {
      return _levels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // COMPLETAR NIVEL COMPLETO
  // ------------------------------------------------------------

  void completeLevel(GameResultModel result) {
    _service.applyGameResult(result);

    final index = _levels.indexWhere(
      (level) => level.id == result.levelId,
    );

    if (index == -1) {
      notifyListeners();
      return;
    }

    _levels[index] = _levels[index].copyWith(
      completed: result.passed,
    );

    // Desbloquea la siguiente misión.
    if (result.passed && index + 1 < _levels.length) {
      _levels[index + 1] = _levels[index + 1].copyWith(
        unlocked: true,
      );
    }

    notifyListeners();
  }
}