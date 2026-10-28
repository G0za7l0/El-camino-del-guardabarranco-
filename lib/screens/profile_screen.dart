import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/progress_controller.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../widgets/achievement_card.dart';
import '../widgets/bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProgressController progress = ProgressController.instance;
  final ProfileService _profileService = ProfileService();

  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = AuthController.instance;

    final userId = auth.userId;
    final token = auth.token;

    // Si todavía no tenemos los datos de autenticación,
    // mantenemos el perfil local.
    if (userId == null || token == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final data = await _profileService.getProfile(
        userId: userId,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _profile = ProfileModel.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      // Si la API falla, la interfaz continúa funcionando
      // con el progreso local.
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      debugPrint('Error cargando perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: AppRoutes.profile,
      ),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final nivel = progress.currentLevel;
final puntos = progress.experience;
final pitahayas = progress.pitahayas;
final racha = progress.streakDays;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),

                if (_profile != null) ...[
                  Text(
                    _profile!.nivelTitulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile!.gradoEscolar,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Text(
                  '¡Casi en el Nivel ${nivel + 1}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Text(
                            'EXPERIENCIA (XP)',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$puntos XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_profile != null)
                            Text(
                              'Nivel ${_profile!.nivelNumero}',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _profile != null
                              ? ((puntos % 1000) / 1000)
                                  .clamp(0.0, 1.0)
                              : progress.experienceProgress,
                          minHeight: 10,
                          backgroundColor:
                              AppColors.backgroundLight,
                          valueColor:
                              const AlwaysStoppedAnimation(
                            AppColors.skyBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.eco,
                        color: AppColors.pitahayaOrange,
                        value: '$pitahayas',
                        label: 'PITAHAYAS',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                        value: '$racha',
                        label: 'DÍAS DE RACHA',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: progress.achievements
                      .map(
                        (a) => AchievementCard(
                          achievement: a,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}