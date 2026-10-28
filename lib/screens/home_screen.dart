import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_text.dart';
import '../controllers/auth_controller.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onStart(BuildContext context) {
    final loggedIn = AuthController.instance.isLoggedIn;

    Navigator.of(context).pushNamed(
      loggedIn ? AppRoutes.missions : AppRoutes.explorer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Tamaños adaptables para teléfonos pequeños.
          final horizontalPadding = screenWidth * 0.065;
          final logoWidth = (screenWidth * 0.86).clamp(170.0, 260.0);
          final bottomIconRadius =
              (screenWidth * 0.07).clamp(22.0, 30.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // FONDO PRINCIPAL
              // ============================================================
              //
              // El fondo ya contiene el escenario/mapa.
              // NO colocar AppAssets.mapPath encima porque duplicaría
              // la imagen del fondo.
              //
              Image.asset(
                AppAssets.homeBackground,
                fit: BoxFit.cover,
              ),

              // Capa muy ligera para mejorar la lectura.
              IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.03),
                ),
              ),

              // ============================================================
              // CONTENIDO
              // ============================================================
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: screenHeight * 0.025,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ------------------------------------------------
                          // LOGO
                          // ------------------------------------------------
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.015,
                            ),
                            child: Image.asset(
                                'assets/branding/logotransp.png',
                                width: logoWidth,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                          ),

                          // ------------------------------------------------
                          // SUBTÍTULO
                          // ------------------------------------------------
                          

                          // Espacio flexible.
                          SizedBox(
                            height: screenHeight * 0.035,
                          ),

                          // ------------------------------------------------
                          // BOTÓN PRINCIPAL
                          // ------------------------------------------------
                       Padding(
  padding: EdgeInsets.only(
    top: screenHeight * 0.09,
  ),
  child: SizedBox(
    width: double.infinity,
    child: PrimaryButton(
      label: AppText.startAdventure,
      icon: Icons.play_arrow_rounded,
      onPressed: () => _onStart(context),
    ),
  ),
),

                          // ------------------------------------------------
                          // NAVEGACIÓN INFERIOR
                          // ------------------------------------------------
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _bottomIcon(
                                icon: Icons.menu_book_rounded,
                                color: AppColors.skyBlue,
                                radius: bottomIconRadius,
                                onTap: () {},
                              ),

                              _bottomIcon(
                                icon: Icons.emoji_events_rounded,
                                color: AppColors.sunYellow,
                                radius: bottomIconRadius,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.profile,
                                  );
                                },
                              ),

                              _bottomIcon(
                                icon: Icons.person_rounded,
                                color: AppColors.oceanBlue,
                                radius: bottomIconRadius,
                                onTap: () {
                                  final loggedIn =
                                      AuthController.instance.isLoggedIn;

                                  Navigator.of(context).pushNamed(
                                    loggedIn
                                        ? AppRoutes.profile
                                        : AppRoutes.explorer,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomIcon({
    required IconData icon,
    required Color color,
    required double radius,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius + 8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
              size: radius * 0.85,
            ),
          ),
        ),
      ),
    );
  }
}