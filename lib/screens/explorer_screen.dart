import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_text.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/explorer_card.dart';
import '../widgets/primary_button.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  ExplorerType _selected = ExplorerType.male;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    setState(() => _submitting = true);
    final success = await AuthController.instance.register(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      explorerType: _selected,
    );
    setState(() => _submitting = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.missions);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthController.instance.errorMessage ??
              'No se pudo crear la cuenta'),
          backgroundColor: AppColors.incorrectRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.forestBackground, fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    AppText.chooseExplorer,
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExplorerCard(
                        assetPath: AppAssets.explorerMale,
                        type: ExplorerType.male,
                        selected: _selected == ExplorerType.male,
                        backgroundColor: AppColors.skyBlue,
                        onTap: () => setState(() => _selected = ExplorerType.male),
                      ),
                      const SizedBox(width: 16),
                      ExplorerCard(
                        assetPath: AppAssets.explorerFemale,
                        type: ExplorerType.female,
                        selected: _selected == ExplorerType.female,
                        backgroundColor: AppColors.leafGreen,
                        onTap: () => setState(() => _selected = ExplorerType.female),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    label: AppText.fullName,
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  CustomTextField(
                    label: AppText.email,
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    label: AppText.password,
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    hint: AppText.minChars,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: AppText.createAccount,
                    onPressed: _submitting ? null : _createAccount,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
  onPressed: _submitting
    ? null
    : () => Navigator.of(context)
        .pushReplacementNamed(AppRoutes.login),
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
  ),
        child: Text(
          AppText.alreadyHaveAccount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
