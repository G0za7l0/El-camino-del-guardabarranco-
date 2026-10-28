import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../controllers/progress_controller.dart';
import '../../models/game_result_model.dart';

class EnglishMatchGameScreen extends StatefulWidget {
  const EnglishMatchGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<EnglishMatchGameScreen> createState() =>
      _EnglishMatchGameScreenState();
}

class _EnglishMatchGameScreenState
    extends State<EnglishMatchGameScreen>
    with SingleTickerProviderStateMixin {
  // ----------------------------------------------------------
  // ANIMACIÓN DEL FONDO
  // ----------------------------------------------------------

  late final AnimationController _backgroundController;

  late final Animation<double> _backgroundScale;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _backgroundScale = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ----------------------------------------------------------
  // PAREJAS CORRECTAS
  // ----------------------------------------------------------

  final Map<String, String> _correctMatches = const {
    'Dog': 'DOG',
    'Cat': 'CAT',
    'Pig': 'PIG',
  };

  final Map<String, String?> _selectedWords = {
    'Dog': null,
    'Cat': null,
    'Pig': null,
  };

  String? _selectedAnimal;
  String? _selectedWord;

  bool _completed = false;
  bool _wrong = false;
  bool _movingToNextGame = false;

  // ----------------------------------------------------------
  // ANIMALES DESORDENADOS
  // ----------------------------------------------------------

  final List<_AnimalMatch> _animals = const [
    _AnimalMatch(
      name: 'Cat',
      assetPath: 'assets/games/gatito.png',
    ),
    _AnimalMatch(
      name: 'Pig',
      assetPath: 'assets/games/cerdito.png',
    ),
    _AnimalMatch(
      name: 'Dog',
      assetPath: 'assets/games/perrito.png',
    ),
  ];

  // ----------------------------------------------------------
  // PALABRAS DESORDENADAS
  // ----------------------------------------------------------

  final List<_WordMatch> _words = const [
    _WordMatch(
      word: 'PIG',
      assetPath: 'assets/games/pig palabra.png',
    ),
    _WordMatch(
      word: 'DOG',
      assetPath: 'assets/games/dog palabra.png',
    ),
    _WordMatch(
      word: 'CAT',
      assetPath: 'assets/games/cat palabra.png',
    ),
  ];

  // ----------------------------------------------------------
  // SELECCIONAR ANIMAL
  // ----------------------------------------------------------

  void _selectAnimal(String animal) {
    if (_completed || _movingToNextGame) return;

    if (_selectedWords[animal] != null) return;

    setState(() {
      _selectedAnimal = animal;
      _wrong = false;
    });

    _tryMatch();
  }

  // ----------------------------------------------------------
  // SELECCIONAR PALABRA
  // ----------------------------------------------------------

  void _selectWord(String word) {
    if (_completed || _movingToNextGame) return;

    if (_selectedWords.values.contains(word)) return;

    setState(() {
      _selectedWord = word;
      _wrong = false;
    });

    _tryMatch();
  }

  // ----------------------------------------------------------
  // COMPROBAR PAREJA
  // ----------------------------------------------------------

  void _tryMatch() {
    if (_selectedAnimal == null ||
        _selectedWord == null) {
      return;
    }

    final animal = _selectedAnimal!;
    final word = _selectedWord!;

    if (_correctMatches[animal] == word) {
      setState(() {
        _selectedWords[animal] = word;
        _selectedAnimal = null;
        _selectedWord = null;
        _wrong = false;
      });

      if (_selectedWords.values
          .every((value) => value != null)) {
        setState(() {
          _completed = true;
        });
      }
    } else {
      setState(() {
        _wrong = true;
      });

      Future.delayed(
        const Duration(milliseconds: 700),
        () {
          if (!mounted) return;

          setState(() {
            _selectedAnimal = null;
            _selectedWord = null;
            _wrong = false;
          });
        },
      );
    }
  }

  // ----------------------------------------------------------
  // COMPLETAR NIVEL
  // ----------------------------------------------------------

  void _finish() {
    if (!_completed || _movingToNextGame) return;

    setState(() {
      _movingToNextGame = true;
    });

    final result = GameResultModel(
      levelId: widget.levelId,
      levelTitle: 'English Level 1',
      correctAnswers: 4,
      totalQuestions: 4,
      points: 20,
      badgeEarned: 'English Explorer',
    );

    ProgressController.instance.completeLevel(result);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.levelCompleted,
      arguments: result,
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // INTERFAZ
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ----------------------------------------------------
            // FONDO ANIMADO
            // ----------------------------------------------------

            Positioned.fill(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _backgroundScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _backgroundScale.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/backgrounds/fondo_granada.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------
            // CAPA SUAVE PARA QUE EL CONTENIDO SE LEA BIEN
            // ----------------------------------------------------

            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.18),
              ),
            ),

            // ----------------------------------------------------
            // CONTENIDO
            // ----------------------------------------------------

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall =
                    constraints.maxWidth < 380;

                return SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    18,
                  ),
                  child: Column(
                    children: [
                      // ------------------------------------------
                      // ENCABEZADO
                      // ------------------------------------------

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.88),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color:
                                    AppColors.darkGreen,
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .maybePop();
                              },
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.90),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'English • Level 1',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 17,
                                color:
                                    AppColors.darkGreen,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------
                      // INSTRUCCIÓN
                      // ------------------------------------------

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.92),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Match each animal with its word!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.darkGreen,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Relaciona cada animal con su palabra.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------
                      // ANIMALES Y PALABRAS
                      // ------------------------------------------

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ======================================
                          // ANIMALES
                          // ======================================

                          Expanded(
                            child: Column(
                              children:
                                  _animals.map((animal) {
                                final matched =
                                    _selectedWords[
                                            animal.name] !=
                                        null;

                                final selected =
                                    _selectedAnimal ==
                                        animal.name;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child:
                                      GestureDetector(
                                    onTap: matched
                                        ? null
                                        : () =>
                                            _selectAnimal(
                                              animal.name,
                                            ),
                                    child:
                                        AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds: 180,
                                      ),
                                      height: isSmall
                                          ? 105
                                          : 120,
                                      decoration:
                                          BoxDecoration(
                                        color: matched
                                            ? AppColors
                                                .primaryGreen
                                                .withOpacity(
                                                0.16,
                                              )
                                            : Colors.white
                                                .withOpacity(
                                                0.94,
                                              ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          18,
                                        ),
                                        border:
                                            Border.all(
                                          color: matched
                                              ? AppColors
                                                  .primaryGreen
                                              : selected
                                                  ? AppColors
                                                      .skyBlue
                                                  : AppColors
                                                      .darkGreen,
                                          width:
                                              selected ||
                                                      matched
                                                  ? 3
                                                  : 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color:
                                                Colors.black12,
                                            blurRadius: 6,
                                            offset:
                                                Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        animal.assetPath,
                                        fit:
                                            BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ======================================
                          // PALABRAS
                          // ======================================

                          Expanded(
                            child: Column(
                              children:
                                  _words.map((word) {
                                final matched =
                                    _selectedWords
                                        .values
                                        .contains(
                                      word.word,
                                    );

                                final selected =
                                    _selectedWord ==
                                        word.word;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child:
                                      GestureDetector(
                                    onTap: matched
                                        ? null
                                        : () =>
                                            _selectWord(
                                              word.word,
                                            ),
                                    child:
                                        AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds: 180,
                                      ),
                                      height: isSmall
                                          ? 105
                                          : 120,
                                      decoration:
                                          BoxDecoration(
                                        color: matched
                                            ? AppColors
                                                .primaryGreen
                                                .withOpacity(
                                                0.16,
                                              )
                                            : Colors.white
                                                .withOpacity(
                                                0.94,
                                              ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          18,
                                        ),
                                        border:
                                            Border.all(
                                          color: matched
                                              ? AppColors
                                                  .primaryGreen
                                              : selected
                                                  ? AppColors
                                                      .skyBlue
                                                  : AppColors
                                                      .darkGreen,
                                          width:
                                              selected ||
                                                      matched
                                                  ? 3
                                                  : 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color:
                                                Colors.black12,
                                            blurRadius: 6,
                                            offset:
                                                Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        word.assetPath,
                                        fit:
                                            BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ------------------------------------------
                      // ERROR
                      // ------------------------------------------

                      if (_wrong)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.92),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Try again!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      // ------------------------------------------
                      // COMPLETADO
                      // ------------------------------------------

                      if (_completed)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.94),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Excellent! 🎉',
                            style: TextStyle(
                              color:
                                  AppColors.primaryGreen,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ------------------------------------------
                      // ÚNICO BOTÓN
                      // ------------------------------------------

                      if (_completed)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _movingToNextGame
                                    ? null
                                    : _finish,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primaryGreen,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Complete level',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ------------------------------------------
                      // PROGRESO
                      // ------------------------------------------

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.90),
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Level 1',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.darkGreen,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                                child:
                                    const LinearProgressIndicator(
                                  value: 1.0,
                                  minHeight: 10,
                                  backgroundColor:
                                      Colors.white,
                                  valueColor:
                                      AlwaysStoppedAnimation(
                                    AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------
// MODELO DE ANIMAL
// --------------------------------------------------------------

class _AnimalMatch {
  const _AnimalMatch({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}

// --------------------------------------------------------------
// MODELO DE PALABRA
// --------------------------------------------------------------

class _WordMatch {
  const _WordMatch({
    required this.word,
    required this.assetPath,
  });

  final String word;
  final String assetPath;
}