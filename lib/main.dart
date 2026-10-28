import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'constants/app_routes.dart';
import 'models/game_result_model.dart';
import 'screens/explorer_screen.dart';
import 'screens/games/balloons_game_screen.dart';
import 'screens/games/bones_game_screen.dart';
import 'screens/games/chest_game_screen.dart';
import 'screens/games/monster_game_screen.dart';
import 'screens/games/puzzle_game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/level_completed_screen.dart';
import 'screens/map_screen.dart';
import 'screens/missions_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/games/bridge_game_screen.dart';
import 'screens/games/english_listen_game_screen.dart';
import 'screens/games/english_word_game_screen.dart';
import 'screens/games/english_water_game_screen.dart';
import 'screens/games/english_match_game_screen.dart';


import 'screens/login_screen.dart';

void main() {
  runApp(const ElCaminoDelGuardabarrancoApp());
}

class ElCaminoDelGuardabarrancoApp extends StatelessWidget {
  const ElCaminoDelGuardabarrancoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Camino del Guardabarranco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.explorer:
        return MaterialPageRoute(builder: (_) => const ExplorerScreen());

      case AppRoutes.missions:
        return MaterialPageRoute(builder: (_) => const MissionsScreen());

      case AppRoutes.map:
        return MaterialPageRoute(builder: (_) => const MapScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.gameBones:
        return MaterialPageRoute(
          builder: (_) => BonesGameScreen(levelId: settings.arguments as int),
        );

      case AppRoutes.gamePuzzle:
        return MaterialPageRoute(
          builder: (_) => PuzzleGameScreen(levelId: settings.arguments as int),
        );

      case AppRoutes.gameChest:
        return MaterialPageRoute(
          builder: (_) => ChestGameScreen(levelId: settings.arguments as int),
        );

      case AppRoutes.gameMonster:
        return MaterialPageRoute(
          builder: (_) => MonsterGameScreen(levelId: settings.arguments as int),
        );

      case AppRoutes.gameBridge:
        return MaterialPageRoute(
          builder: (_) => BridgeGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      case AppRoutes.gameBalloons:
        return MaterialPageRoute(
          builder: (_) => BalloonsGameScreen(levelId: settings.arguments as int),
        );

            case AppRoutes.gameBalloons:
        return MaterialPageRoute(
          builder: (_) => BalloonsGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      // 🇬🇧 JUEGOS DE INGLÉS

      case AppRoutes.gameEnglishListen:
        return MaterialPageRoute(
          builder: (_) => EnglishListenGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      case AppRoutes.gameEnglishWord:
        return MaterialPageRoute(
          builder: (_) => EnglishWordGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      case AppRoutes.gameEnglishWater:
        return MaterialPageRoute(
          builder: (_) => EnglishWaterGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      case AppRoutes.gameEnglishMatch:
        return MaterialPageRoute(
          builder: (_) => EnglishMatchGameScreen(
            levelId: settings.arguments as int,
          ),
        );

      case AppRoutes.levelCompleted:
        return MaterialPageRoute(
          builder: (_) => LevelCompletedScreen(
            result: settings.arguments as GameResultModel,
          ),
        );


      case AppRoutes.levelCompleted:
        return MaterialPageRoute(
          builder: (_) => LevelCompletedScreen(
            result: settings.arguments as GameResultModel,
          ),
        );

        case AppRoutes.login:
  return MaterialPageRoute(
    builder: (_) => const LoginScreen(),
  );

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
