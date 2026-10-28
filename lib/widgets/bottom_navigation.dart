import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_routes.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.currentRoute});

  final String currentRoute;

  void _go(BuildContext context, String route) {
    if (route == currentRoute) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppRoutes.map, Icons.map_rounded, 'Mapa'),
      (AppRoutes.missions, Icons.assignment_rounded, 'Misiones'),
      (AppRoutes.profile, Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final isActive = item.$1 == currentRoute;
          final color = isActive ? AppColors.primaryGreen : AppColors.textGrey;
          return GestureDetector(
            onTap: () => _go(context, item.$1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$2, color: color),
                const SizedBox(height: 2),
                Text(item.$3, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
