import '../constants/app_assets.dart';
import '../models/achievement_model.dart';
import '../models/level_model.dart';
import '../models/question_model.dart';

/// Datos locales/mock. Los modelos ya están preparados para recibir
/// esta misma información desde una API en el futuro.
class MockData {
  MockData._();

  // ------------------------------------------------------------------
  // Niveles / Misiones de Hoy
  // ------------------------------------------------------------------
  static List<LevelModel> levels = [
  const LevelModel(
    id: 1,
    title: 'Aventura Matemática en el Bosque Nuboso',
    description: 'Matemática',
    subject: MissionSubject.matematica,
    challenges: [
      GameType.bones,
      GameType.puzzle,
      GameType.chest,
      GameType.monster,
      GameType.balloons,
      GameType.bridge,
    ],
    rewardXp: 420,
    rewardPitahayas: 175,
    unlocked: true,
  ),

  const LevelModel(
  id: 101,
  title: 'Vocabulario de la selva y expedición',
  description: 'Inglés',
  subject: MissionSubject.ingles,
  challenges: [
    GameType.englishListen,
    GameType.englishWord,
    GameType.englishWater,
    GameType.englishMatch,
  ],
  rewardXp: 30,
  rewardPitahayas: 15,
  unlocked: true,
),

  const LevelModel(
    id: 102,
    title: 'Palabras y aventuras por Nicaragua',
    description: 'Español',
    subject: MissionSubject.espanol,
    challenges: [
      GameType.bones,
    ],
    rewardXp: 30,
    rewardPitahayas: 15,
    unlocked: false,
  ),
];

  // ------------------------------------------------------------------
  // Preguntas - Huesos
  // ------------------------------------------------------------------
  static List<QuestionModel> bonesQuestions = const [
    QuestionModel(
      prompt: 'Atrapa el hueso con el resultado correcto',
      operandA: 6,
      operandB: 7,
      correctAnswer: 13,
      options: [
        AnswerOption(value: 11, assetPath: AppAssets.bone11),
        AnswerOption(value: 12, assetPath: AppAssets.bone12),
        AnswerOption(value: 13, assetPath: AppAssets.bone13),
      ],
    ),
  ];

  // ------------------------------------------------------------------
  // Preguntas - Puzzle
  // ------------------------------------------------------------------
  static List<QuestionModel> puzzleQuestions = const [
    QuestionModel(
      prompt: 'Arrastra la pieza con la respuesta de la suma',
      operandA: 7,
      operandB: 5,
      correctAnswer: 12,
      options: [
        AnswerOption(value: 10, assetPath: AppAssets.puzzle10),
        AnswerOption(value: 12, assetPath: AppAssets.puzzle12),
        AnswerOption(value: 15, assetPath: AppAssets.puzzle15),
      ],
    ),
  ];

  // ------------------------------------------------------------------
  // Preguntas - Cofre
  // ------------------------------------------------------------------
  static List<QuestionModel> chestQuestions = const [
    QuestionModel(
      prompt: 'Resuelve 5 sumas para abrir el cofre',
      operandA: 4,
      operandB: 6,
      correctAnswer: 10,
      options: [
        AnswerOption(value: 10, assetPath: ''),
        AnswerOption(value: 19, assetPath: ''),
        AnswerOption(value: 11, assetPath: ''),
      ],
    ),
    QuestionModel(
      prompt: 'Resuelve 5 sumas para abrir el cofre',
      operandA: 3,
      operandB: 5,
      correctAnswer: 8,
      options: [
        AnswerOption(value: 7, assetPath: ''),
        AnswerOption(value: 10, assetPath: ''),
        AnswerOption(value: 8, assetPath: ''),
      ],
    ),
    QuestionModel(
      prompt: 'Resuelve 5 sumas para abrir el cofre',
      operandA: 2,
      operandB: 9,
      correctAnswer: 11,
      options: [
        AnswerOption(value: 10, assetPath: ''),
        AnswerOption(value: 11, assetPath: ''),
        AnswerOption(value: 12, assetPath: ''),
      ],
    ),
    QuestionModel(
      prompt: 'Resuelve 5 sumas para abrir el cofre',
      operandA: 5,
      operandB: 5,
      correctAnswer: 10,
      options: [
        AnswerOption(value: 10, assetPath: ''),
        AnswerOption(value: 11, assetPath: ''),
        AnswerOption(value: 9, assetPath: ''),
      ],
    ),
    QuestionModel(
      prompt: 'Resuelve 5 sumas para abrir el cofre',
      operandA: 6,
      operandB: 6,
      correctAnswer: 12,
      options: [
        AnswerOption(value: 11, assetPath: ''),
        AnswerOption(value: 12, assetPath: ''),
        AnswerOption(value: 13, assetPath: ''),
      ],
    ),
  ];

  // ------------------------------------------------------------------
  // Preguntas - Monstruo
  // ------------------------------------------------------------------
  static List<QuestionModel> monsterQuestions = const [
    QuestionModel(
      prompt: '¡El monstruo tiene hambre! Dale la comida con el resultado correcto',
      operandA: 8,
      operandB: 6,
      correctAnswer: 14,
      options: [
        AnswerOption(value: 13, assetPath: AppAssets.apple13),
        AnswerOption(value: 14, assetPath: AppAssets.banana14),
        AnswerOption(value: 15, assetPath: AppAssets.strawberry15),
      ],
    ),
  ];

  // ------------------------------------------------------------------
  // Preguntas - Globos
  // ------------------------------------------------------------------
  static List<QuestionModel> balloonsQuestions = const [
    QuestionModel(
      prompt: 'Pincha el globo con el resultado de la suma',
      operandA: 9,
      operandB: 4,
      correctAnswer: 13,
      options: [
        AnswerOption(value: 12, assetPath: AppAssets.balloon12),
        AnswerOption(value: 13, assetPath: AppAssets.balloon13),
        AnswerOption(value: 14, assetPath: AppAssets.balloon14),
      ],
    ),
  ];

  // ------------------------------------------------------------------
  // Logros / Insignias
  // ------------------------------------------------------------------
  static List<AchievementModel> achievements = const [
    AchievementModel(
      id: 'explorador_managua',
      title: 'Explorador de Managua',
      description: 'Visita 5 hitos históricos',
      unlocked: true,
    ),
    AchievementModel(
      id: 'guardian_letras',
      title: 'Guardián de Letras',
      description: 'Termina el curso de Gramática',
      unlocked: true,
    ),
    AchievementModel(
      id: 'maestro_volcanico',
      title: 'Maestro Volcánico',
      description: '???',
      unlocked: false,
    ),
    AchievementModel(
      id: 'cacao_legendario',
      title: 'Cacao Legendario',
      description: '???',
      unlocked: false,
    ),
    AchievementModel(
      id: 'maestro_sumas',
      title: 'Maestro de las Sumas',
      description: 'Completa un nivel de sumas',
      unlocked: false,
    ),
  ];

  // ------------------------------------------------------------------
  // Ubicaciones del mapa de aventura
  // ------------------------------------------------------------------
 static List<MapLocationModel> mapLocations = const [
  MapLocationModel(
    id: 'rio_san_juan',
    name: 'Río San Juan',
    dx: 0.60,
    dy: 0.72,
    unlocked: true,
    completed: false,
  ),
  MapLocationModel(
    id: 'raas',
    name: 'RAAS',
    dx: 0.78,
    dy: 0.50,
    unlocked: false,
    completed: false,
  ),
  MapLocationModel(
    id: 'granada',
    name: 'Granada',
    dx: 0.28,
    dy: 0.62,
    unlocked: false,
    completed: false,
  ),
  MapLocationModel(
    id: 'bluefields',
    name: 'Bluefields',
    dx: 0.36,
    dy: 0.32,
    unlocked: false,
    completed: false,
  ),
  MapLocationModel(
    id: 'corn_island',
    name: 'Corn Island',
    dx: 0.86,
    dy: 0.16,
    unlocked: false,
    completed: false,
  ),
];
}