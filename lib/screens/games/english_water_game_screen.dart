import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class EnglishWaterGameScreen extends StatefulWidget {
  const EnglishWaterGameScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  State<EnglishWaterGameScreen> createState() =>
      _EnglishWaterGameScreenState();
}

class _EnglishWaterGameScreenState
    extends State<EnglishWaterGameScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAnimal;
  bool _completed = false;
  bool _wrong = false;
  bool _movingToNextGame = false;

  // ----------------------------------------------------------
  // ANIMACIÓN DEL FONDO
  // ----------------------------------------------------------

  late final AnimationController _backgroundController;

  late final Animation<double> _backgroundScale;

  // ----------------------------------------------------------
  // ANIMALES
  // ----------------------------------------------------------

  final List<_WaterAnimalOption> _options = const [
    _WaterAnimalOption(
      name: 'Fish',
      assetPath: 'assets/games/pez.png',
    ),
    _WaterAnimalOption(
      name: 'Dolphin',
      assetPath: 'assets/games/delfin.png',
    ),
    _WaterAnimalOption(
      name: 'Monkey',
      assetPath: 'assets/games/mono colgado.png',
    ),
    _WaterAnimalOption(
      name: 'Turtle',
      assetPath: 'assets/games/tortuga.png',
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
  // SELECCIONAR ANIMAL
  // ----------------------------------------------------------

  void _selectAnimal(String animal) {
    if (_completed || _movingToNextGame) return;

    setState(() {
      _selectedAnimal = animal;

      if (animal == 'Monkey') {
        _completed = true;
        _wrong = false;
      } else {
        _completed = false;
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
      AppRoutes.gameEnglishMatch,
      arguments: widget.levelId,
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
            // CAPA SUAVE
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
                      // ------------------------------------------
                      // ENCABEZADO
                      // ------------------------------------------

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
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.90),
                              borderRadius:
                                  BorderRadius.circular(20),
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

                      // ------------------------------------------
                      // PREGUNTA
                      // ------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.darkGreen,
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
                          'WHICH ANIMAL DOES NOT LIVE IN THE WATER?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ------------------------------------------
                      // ANIMALES
                      // ------------------------------------------

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: _options.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              isSmall ? 1.05 : 1.15,
                        ),
                        itemBuilder: (context, index) {
                          final option = _options[index];

                          final selected =
                              _selectedAnimal == option.name;

                          final correct =
                              _completed &&
                              option.name == 'Monkey';

                          return GestureDetector(
                            onTap: () {
                              _selectAnimal(option.name);
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.94),
                                borderRadius:
                                    BorderRadius.circular(18),
                                border: Border.all(
                                  color: correct
                                      ? AppColors.primaryGreen
                                      : selected
                                          ? AppColors.skyBlue
                                          : AppColors.darkGreen,
                                  width:
                                      selected || correct ? 3 : 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(8),
                                      child: Image.asset(
                                        option.assetPath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    option.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------
                      // FEEDBACK
                      // ------------------------------------------

                      if (_wrong)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius:
                                BorderRadius.circular(15),
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
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Correct! 🎉',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ------------------------------------------
                      // SOLO CONTINUE
                      // ------------------------------------------

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

                      // ------------------------------------------
                      // PROGRESO
                      // ------------------------------------------

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius:
                              BorderRadius.circular(15),
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
                                child:
                                    const LinearProgressIndicator(
                                  value: 0.75,
                                  minHeight: 10,
                                  backgroundColor: Colors.white,
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

class _WaterAnimalOption {
  const _WaterAnimalOption({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}