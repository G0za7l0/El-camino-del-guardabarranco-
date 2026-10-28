class AchievementModel {
  final String id;
  final String title;
  final String description;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
  });

  AchievementModel copyWith({bool? unlocked}) => AchievementModel(
        id: id,
        title: title,
        description: description,
        unlocked: unlocked ?? this.unlocked,
      );
}

class MapLocationModel {
  final String id;
  final String name;
  final double dx; // posición relativa horizontal (0-1) sobre el mapa
  final double dy; // posición relativa vertical (0-1) sobre el mapa
  final bool unlocked;
  final bool completed;

  const MapLocationModel({
    required this.id,
    required this.name,
    required this.dx,
    required this.dy,
    this.unlocked = false,
    this.completed = false,
  });
}
