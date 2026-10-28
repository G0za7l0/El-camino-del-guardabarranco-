import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../controllers/progress_controller.dart';
import '../data/mock_data.dart';
import '../models/achievement_model.dart';
import '../models/level_model.dart';
import '../widgets/bottom_navigation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLocationModel? _selected;

  LevelModel? _levelForLocation(
  MapLocationModel location,
  ProgressController progress,
) {
  switch (location.id) {
    case 'rio_san_juan':
      // Nivel 1: Matemáticas
      return progress.levelById(1);

    case 'raas':
      // Nivel 101: Inglés
      return progress.levelById(101);

    default:
      return null;
  }
}

  void _selectLocation(MapLocationModel location) {
    setState(() {
      _selected = location;
    });
  }

  void _continueAdventure(
    BuildContext context,
    LevelModel? level,
  ) {
    if (level == null || !level.unlocked) return;

    if (level.subject == MissionSubject.matematica) {
      Navigator.of(context).pushNamed(
        AppRoutes.gameBones,
        arguments: level.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressController.instance;
    final locations = MockData.mapLocations;

    return Scaffold(
      backgroundColor: Colors.transparent,

      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: AppRoutes.map,
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ----------------------------------------------------------
          // MAPA COMPLETO
          // ----------------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              AppAssets.mapPath,
              fit: BoxFit.cover,
            ),
          ),

          // ----------------------------------------------------------
          // CAPA SUPERIOR SUAVE PARA QUE EL HEADER SE LEA
          // ----------------------------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.darkGreen,
                        ),
                        onPressed: () =>
                            Navigator.of(context).maybePop(),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: progress,
                        builder: (context, _) {
                          return Row(
                            children: [
                              const Icon(
                                Icons.eco,
                                color: AppColors.pitahayaOrange,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${progress.pitahayas}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // PUNTOS DEL MAPA
          // ----------------------------------------------------------
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: locations.map((location) {
                    final level = _levelForLocation(
                      location,
                      progress,
                    );

                    return Positioned(
                      left: location.dx * constraints.maxWidth - 22,
                      top: location.dy * constraints.maxHeight - 22,
                      child: GestureDetector(
                        onTap: () => _selectLocation(location),
                        child: _LocationMarker(
                          location: location,
                          level: level,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // ----------------------------------------------------------
          // INFORMACIÓN DEL DEPARTAMENTO SELECCIONADO
          // ----------------------------------------------------------
          if (_selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) {
                    final level = _levelForLocation(
                      _selected!,
                      progress,
                    );

                    return _LevelInfoCard(
                      location: _selected!,
                      level: level,
                      onContinue: () => _continueAdventure(
                        context,
                        level,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ====================================================================
// MARCADOR
// ====================================================================

class _LocationMarker extends StatelessWidget {
  const _LocationMarker({
    required this.location,
    required this.level,
  });

  final MapLocationModel location;
  final LevelModel? level;

  @override
  Widget build(BuildContext context) {
    final bool completed = level?.completed ?? location.completed;
    final bool unlocked = level?.unlocked ?? location.unlocked;

    final Color color = completed
        ? AppColors.correctGreen
        : unlocked
            ? AppColors.sunYellow
            : AppColors.lockedGrey;

    final IconData icon = completed
        ? Icons.check
        : unlocked
            ? Icons.star
            : Icons.lock;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            shadows: [
              Shadow(
                color: Colors.white,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// TARJETA DEL NIVEL
// ====================================================================

class _LevelInfoCard extends StatelessWidget {
  const _LevelInfoCard({
    required this.location,
    required this.level,
    required this.onContinue,
  });

  final MapLocationModel location;
  final LevelModel? level;
  final VoidCallback onContinue;

  String get _subjectName {
    if (level == null) {
      return 'Próximamente';
    }

    switch (level!.subject) {
      case MissionSubject.matematica:
        return 'Matemáticas';
      case MissionSubject.ingles:
        return 'Inglés';
      case MissionSubject.espanol:
        return 'Español';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool unlocked = level?.unlocked ?? false;
    final bool completed = level?.completed ?? false;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subjectName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  completed
                      ? 'Nivel completado'
                      : unlocked
                          ? 'Aventura disponible'
                          : level == null
                              ? 'Nivel por descubrir'
                              : 'Nivel bloqueado',
                  style: TextStyle(
                    color: completed
                        ? AppColors.correctGreen
                        : unlocked
                            ? AppColors.primaryGreen
                            : AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: unlocked && level != null
                ? onContinue
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lockedGrey,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              unlocked
                  ? 'CONTINUAR\nAVENTURA'
                  : 'BLOQUEADO',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}