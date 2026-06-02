import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    await AuthSession.instance.initialize();

    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final hasSeenTutorial = await storage.read(key: 'hasSeenTutorial');

    if (!mounted) return;

    if (hasSeenTutorial != 'true') {
      context.go('/tutorial');
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removido o 'const' daqui para o Image.asset funcionar
      backgroundColor: const Color(0xFF0C1B33),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // === GIF ADICIONADO AQUI NO LUGAR DA BALANÇA ===
            Image.asset(
              'assets/images/wellcome.gif', // Ajuste o caminho se sua pasta for diferente
              height:
                  120, // Altura que fica equivalente ao size 100 do ícone antigo
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.balance,
                size: 100,
                color: AppColors.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PrecedentIA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.mainWhiteColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.accentColor),
          ],
        ),
      ),
    );
  }
}
