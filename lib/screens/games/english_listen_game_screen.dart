import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class EnglishListenGameScreen extends StatefulWidget {
  const EnglishListenGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<EnglishListenGameScreen> createState() =>
      _EnglishListenGameScreenState();
}

class _EnglishListenGameScreenState
    extends State<EnglishListenGameScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAnimal;
  bool _completed = false;
  bool _movingToNextGame = false;

  final FlutterTts _tts = FlutterTts();

  // ----------------------------------------------------------
  // ANIMACIÓN DEL FONDO
  // ----------------------------------------------------------

  late final AnimationController _backgroundController;

  late final Animation<double> _backgroundScale;

  // ----------------------------------------------------------
  // ANIMALES
  // ----------------------------------------------------------

  final List<_AnimalOption> _options = const [
    _AnimalOption(
      name: 'Elephant',
      assetPath: 'assets/games/elefante.png',
    ),
    _AnimalOption(
      name: 'Lion',
      assetPath: 'assets/games/leon.png',
    ),
    _AnimalOption(
      name: 'Monkey',
      assetPath: 'assets/games/mono.png',
    ),
  ];

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------

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
  // REPRODUCIR "LION" EN INGLÉS
  // ----------------------------------------------------------

  Future<void> _playLionAudio() async {
    try {
      await _tts.stop();

      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.35);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      await _tts.speak('Lion');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo reproducir el audio.',
          ),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // SELECCIONAR ANIMAL
  // ----------------------------------------------------------

  void _selectAnimal(String animal) {
    if (_completed || _movingToNextGame) return;

    setState(() {
      _selectedAnimal = animal;

      if (animal == 'Lion') {
        _completed = true;
      }
    });
  }

  // ----------------------------------------------------------
  // CONTINUAR
  // ----------------------------------------------------------

  void _finish() {
    if (!_completed || _movingToNextGame) return;

    setState(() {
      _movingToNextGame = true;
    });

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.gameEnglishWord,
      arguments: widget.levelId,
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    _backgroundController.dispose();
    _tts.stop();
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
            // FONDO GRANADA ANIMADO
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
            // CAPA SUAVE PARA MEJORAR LA LECTURA
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

                      const SizedBox(height: 16),

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
                          border: Border.all(
                            color:
                                AppColors.darkGreen,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Listen and choose the correct animal!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                            color:
                                AppColors.darkGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ------------------------------------------
                      // BOTÓN DE AUDIO
                      // ------------------------------------------

                      GestureDetector(
                        onTap: _playLionAudio,
                        child: Container(
                          width:
                              isSmall ? 115 : 130,
                          height:
                              isSmall ? 115 : 130,
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.94),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppColors.darkGreen,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/games/sonido lion.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.88),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tap to listen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                AppColors.textGrey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ------------------------------------------
                      // OPCIONES DE ANIMALES
                      // ------------------------------------------

                      Row(
                        children:
                            _options.map((option) {
                          final selected =
                              _selectedAnimal ==
                                  option.name;

                          final correct =
                              _completed &&
                              option.name == 'Lion';

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _selectAnimal(
                                    option.name,
                                  );
                                },
                                child:
                                    AnimatedContainer(
                                  duration:
                                      const Duration(
                                    milliseconds: 180,
                                  ),
                                  height: isSmall
                                      ? 145
                                      : 165,
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white
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
                                      color: correct
                                          ? AppColors
                                              .primaryGreen
                                          : selected
                                              ? AppColors
                                                  .skyBlue
                                              : AppColors
                                                  .darkGreen,
                                      width:
                                          selected ||
                                                  correct
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
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets
                                                  .all(8),
                                          child:
                                              Image.asset(
                                            option
                                                .assetPath,
                                            fit: BoxFit
                                                .contain,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        option.name,
                                        style:
                                            const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              AppColors
                                                  .darkGreen,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------
                      // FEEDBACK
                      // ------------------------------------------

                      if (_selectedAnimal != null)
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
                          child: Text(
                            _completed
                                ? '¡Correct! 🎉'
                                : 'Try again!',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                              color: _completed
                                  ? AppColors
                                      .primaryGreen
                                  : Colors.red,
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      // ------------------------------------------
                      // SOLO CONTINUE
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
                                  AppColors
                                      .primaryGreen,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
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
                              'Continue',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 22),

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
                          color: Colors.white
                              .withOpacity(0.90),
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
                                  value: 0.25,
                                  minHeight: 10,
                                  backgroundColor:
                                      Colors.white,
                                  valueColor:
                                      AlwaysStoppedAnimation(
                                    AppColors
                                        .primaryGreen,
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
// MODELO DE OPCIÓN
// --------------------------------------------------------------

class _AnimalOption {
  const _AnimalOption({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}