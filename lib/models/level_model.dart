enum MissionSubject {
  matematica,
  ingles,
  espanol,
}

enum GameType {
  bones,
  puzzle,
  chest,
  monster,
  balloons,
  bridge,
  englishListen,
  englishWord,
  englishWater,
  englishMatch,
}

class LevelModel {
  final int id;
  final String title;
  final String description;
  final MissionSubject subject;
  final List<GameType> challenges;
  final int rewardXp;
  final int rewardPitahayas;
  final bool unlocked;
  final bool completed;

  const LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.challenges,
    required this.rewardXp,
    required this.rewardPitahayas,
    this.unlocked = false,
    this.completed = false,
  });

  LevelModel copyWith({
    bool? unlocked,
    bool? completed,
  }) {
    return LevelModel(
      id: id,
      title: title,
      description: description,
      subject: subject,
      challenges: challenges,
      rewardXp: rewardXp,
      rewardPitahayas: rewardPitahayas,
      unlocked: unlocked ?? this.unlocked,
      completed: completed ?? this.completed,
    );
  }
}