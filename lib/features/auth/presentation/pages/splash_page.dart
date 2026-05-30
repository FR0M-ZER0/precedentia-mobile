import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/auth_session.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    final isLoggedIn = await AuthSession.instance.initialize();

    if (mounted) {
      context.go(isLoggedIn ? '/' : '/tutorial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.mainDarkColor, // Fundo escuro do projeto
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.balance, size: 100, color: AppColors.accentColor),
            SizedBox(height: 24),
            Text(
              'PrecedentIA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.mainWhiteColor,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: AppColors.accentColor),
          ],
        ),
      ),
    );
  }
}
