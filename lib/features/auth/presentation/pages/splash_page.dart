import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:precedentia_mobile/core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

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
    // Simula um tempo de carregamento para a Splash ficar visível
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 1. Verifica se o usuário já passou do Tutorial
    const storage = FlutterSecureStorage();
    final hasSeenTutorial = await storage.read(key: 'hasSeenTutorial');

    if (hasSeenTutorial != 'true') {
      context.go('/tutorial');
      return; // Para a execução por aqui e vai pro tutorial
    }

    // 2. RECUPERAÇÃO DE SESSÃO DO GOOGLE
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signInSilently();

      if (account != null) {
        // Sessão recuperada com sucesso!
        AppRouter.authNotifier.value = true;
        
        if (mounted) {
          context.go('/'); // Joga direto pra Home
        }
        return;
      }
    } catch (error) {
      debugPrint('Erro ao tentar recuperar sessão: $error');
    }

    // 3. Se já viu o tutorial, mas NÃO tem sessão ativa, vai pro Login
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.mainDarkColor, // Fundo escuro do projeto mantido!
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