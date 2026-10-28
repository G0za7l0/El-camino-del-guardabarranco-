import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class EnglishWordGameScreen extends StatefulWidget {
  const EnglishWordGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<EnglishWordGameScreen> createState() =>
      _EnglishWordGameScreenState();
}

class _EnglishWordGameScreenState extends State<EnglishWordGameScreen>
    with SingleTickerProviderStateMixin {
  // Orden correcto de la palabra
  final List<String> _correctOrder = ['D', 'O', 'G'];

  // Espacios donde se colocan las letras
  final List<String?> _slots = [null, null, null];

  // Letras DESORDENADAS
  final List<_LetterOption> _letters = const [
    _LetterOption(
      letter: 'G',
      assetPath: 'assets/games/letra G.png',
    ),
    _LetterOption(
      letter: 'D',
      assetPath: 'assets/games/letra D.png',
    ),
    _LetterOption(
      letter: 'O',
      assetPath: 'assets/games/letra O.png',
    ),
  ];

  bool _completed = false;
  bool _wrong = false;
  bool _movingToNextGame = false;

  // ----------------------------------------------------------
  // FONDO ANIMADO
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

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // COLOCAR LETRA
  // ----------------------------------------------------------

  void _placeLetter(String letter) {
    if (_completed || _movingToNextGame) return;

    final emptyIndex = _slots.indexOf(null);

    if (emptyIndex == -1) return;

    setState(() {
      _slots[emptyIndex] = letter;
      _wrong = false;
    });

    // Cuando ya están las 3 letras,
    // comprobamos automáticamente.
    if (!_slots.contains(null)) {
      _checkAnswer();
    }
  }

  // ----------------------------------------------------------
  // ELIMINAR LETRA
  // ----------------------------------------------------------

  void _removeLetter(int index) {
    if (_completed || _movingToNextGame) return;

    if (_slots[index] == null) return;

    setState(() {
      _slots[index] = null;
      _wrong = false;
    });
  }

  // ----------------------------------------------------------
  // COMPROBAR RESPUESTA
  // ----------------------------------------------------------

  void _checkAnswer() {
    if (_slots.contains(null)) return;

    final answer = _slots.join();

    setState(() {
      if (answer == _correctOrder.join()) {
        _completed = true;
        _wrong = false;
      } else {
        _wrong = true;
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
      AppRoutes.gameEnglishWater,
      arguments: widget.levelId,
    );
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
            // ------------------------------------------------
            // FONDO GRANADA ANIMADO
            // ------------------------------------------------

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

            // ------------------------------------------------
            // CAPA SUAVE PARA MEJORAR LA LEGIBILIDAD
            // ------------------------------------------------

            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.18),
              ),
            ),

            // ------------------------------------------------
            // CONTENIDO
            // ------------------------------------------------

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 380;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    18,
                  ),
                  child: Column(
                    children: [
                      // ------------------------------------------------
                      // ENCABEZADO
                      // ------------------------------------------------

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.darkGreen,
                              ),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.90),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'English • Level 1',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // INSTRUCCIÓN
                      // ------------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Drag the pieces to name the animal!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¡Arrastra las piezas para nombrar al animal!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // PERRO
                      // ------------------------------------------------

                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          height: isSmall ? 175 : 205,
                          child: Image.asset(
                            'assets/games/perro ingles.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // ESPACIOS DE RESPUESTA
                      // ------------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            3,
                            (index) => DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                if (_completed ||
                                    _movingToNextGame) {
                                  return;
                                }

                                if (_slots[index] != null) return;

                                // Evita colocar una letra que
                                // ya esté ocupando otro espacio.
                                if (_slots.contains(details.data)) {
                                  return;
                                }

                                setState(() {
                                  _slots[index] = details.data;
                                  _wrong = false;
                                });

                                // Comprobar automáticamente
                                // al completar los tres espacios.
                                if (!_slots.contains(null)) {
                                  _checkAnswer();
                                }
                              },
                              builder: (
                                context,
                                candidateData,
                                rejectedData,
                              ) {
                                final letter = _slots[index];

                                return GestureDetector(
                                  onTap: () => _removeLetter(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 150,
                                    ),
                                    width: isSmall ? 82 : 92,
                                    height: isSmall ? 82 : 92,
                                    decoration: BoxDecoration(
                                      color: candidateData.isNotEmpty
                                          ? AppColors.leafGreen
                                              .withOpacity(0.25)
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _completed
                                            ? AppColors.primaryGreen
                                            : AppColors.darkGreen,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: letter == null
                                        ? const Icon(
                                            Icons.add,
                                            size: 30,
                                            color:
                                                AppColors.textGrey,
                                          )
                                        : _letterAsset(letter),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // LETRAS DESORDENADAS
                      // ------------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: _letters.map((option) {
                            final used =
                                _slots.contains(option.letter);

                            return Draggable<String>(
                              data: option.letter,
                              maxSimultaneousDrags:
                                  used || _completed ? 0 : 1,

                              feedback: Material(
                                color: Colors.transparent,
                                child: Image.asset(
                                  option.assetPath,
                                  width: 82,
                                  height: 82,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              childWhenDragging: Opacity(
                                opacity: 0.25,
                                child: Image.asset(
                                  option.assetPath,
                                  width: 82,
                                  height: 82,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              child: GestureDetector(
                                onTap: used
                                    ? null
                                    : () => _placeLetter(
                                        option.letter,
                                      ),
                                child: Opacity(
                                  opacity: used ? 0.35 : 1,
                                  child: Image.asset(
                                    option.assetPath,
                                    width: isSmall ? 78 : 88,
                                    height: isSmall ? 78 : 88,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // FEEDBACK
                      // ------------------------------------------------

                      if (_wrong)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Try again!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      if (_completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '¡Correct! 🎉',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ------------------------------------------------
                      // BOTÓN CONTINUE
                      // ------------------------------------------------

                      if (_completed)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _movingToNextGame ? null : _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // PROGRESO
                      // ------------------------------------------------

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Level 1',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0.50,
                                  minHeight: 10,
                                  backgroundColor:
                                      Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation(
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

  // ----------------------------------------------------------
  // MOSTRAR ASSET DE LETRA
  // ----------------------------------------------------------

  Widget _letterAsset(String letter) {
    final option = _letters.firstWhere(
      (item) => item.letter == letter,
    );

    return Image.asset(
      option.assetPath,
      width: 70,
      height: 70,
      fit: BoxFit.contain,
    );
  }
}

// --------------------------------------------------------------
// MODELO DE LETRA
// --------------------------------------------------------------

class _LetterOption {
  const _LetterOption({
    required this.letter,
    required this.assetPath,
  });

  final String letter;
  final String assetPath;
}