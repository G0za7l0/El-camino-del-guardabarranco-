import '../models/game_result_model.dart';

/// Persistencia LOCAL (en memoria) del progreso del jugador.
/// Todavía no existe API real.
class ProgressService {
  int experience = 2450;
  int experienceRequired = 3000;
  int currentLevel = 12;
  int pitahayas = 120;
  int streakDays = 5;

  final List<String> unlockedAchievementIds = [
    'explorador_managua',
    'guardian_letras',
  ];

  /// Aplica el resultado de un nivel al progreso local del jugador.
  void applyGameResult(GameResultModel result) {
    experience += result.points;
    pitahayas += (result.points / 2).round();

    while (experience >= experienceRequired) {
      experience -= experienceRequired;
      currentLevel += 1;
      experienceRequired = (experienceRequired * 1.1).round();
    }

    if (result.badgeEarned != null &&
        !unlockedAchievementIds.contains(result.badgeEarned)) {
      unlockedAchievementIds.add(result.badgeEarned!);
    }

    // ==================================================
    // API CONNECTION POINT
    // SCREEN: LEVEL COMPLETED
    // ACTION: SAVE LEVEL RESULT
    // ==================================================
    //
    // FUTURE ENDPOINT:
    // POST /api/game/answer
    // POST /api/progress/level-result
    //
    // DATA:
    // - userId
    // - levelId
    // - correctAnswers
    // - totalQuestions
    // - points
    // - badgeEarned
    //
    // TODO:
    // Replace local logic with API call.
    // ==================================================
  }

  // ==================================================
  // API CONNECTION POINT
  // SCREEN: PROFILE
  // ACTION: GET USER PROFILE / PROGRESS
  // ==================================================
  //
  // FUTURE ENDPOINT:
  // GET /api/profile
  // GET /api/progress
  //
  // TODO:
  // Replace in-memory fields above with data fetched from API.
  // ==================================================
}
