import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/home_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/loading_precedents_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_text_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/history_page.dart';

import 'package:precedentia_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/tutorial_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/two_factor_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/reset_password_page.dart';

class AppRouter {
  // Estado global para simular a autenticação (false = deslogado, true = logado)
  static final authNotifier = ValueNotifier<bool>(false);

  static final router = GoRouter(
    initialLocation: '/splash', // O app agora sempre inicia na Splash para checar os dados
    refreshListenable: authNotifier, // O roteador "escuta" quando o usuário loga/desloga

    // Lógica de proteção de rotas (Middleware)
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;

      // Definimos quais rotas o usuário pode acessar sem estar logado
      final isGoingToAuth = state.matchedLocation == '/login' ||
                            state.matchedLocation == '/cadastro' ||
                            state.matchedLocation == '/splash' ||
                            state.matchedLocation == '/tutorial' ||
                            state.matchedLocation == '/2fa' ||
                            state.matchedLocation == '/esqueci-senha' || 
                            state.matchedLocation == '/redefinir-senha'; 

      // 1. Se NÃO estiver logado e tentar acessar rota protegida (ex: Home) -> vai pro Login
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      // 2. Se JÁ estiver logado e tentar acessar Login/Cadastro/Splash -> vai direto pra Home
      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      // 3. Se estiver tudo certo, permite seguir o fluxo normal
      return null;
    },

    routes: [
      // ====================
      // ROTAS PÚBLICAS
      // ====================
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/tutorial',
        name: 'tutorial',
        builder: (context, state) => const TutorialPage(),
      ),

      GoRoute(
        path: '/cadastro',
        name: 'registration',
        builder: (context, state) => const RegistrationPage(),
      ),

      GoRoute(
        path: '/2fa',
        name: 'two_factor',
        builder: (context, state) => const TwoFactorPage(),
      ),

      GoRoute(
        path: '/esqueci-senha',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/redefinir-senha',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // ====================
      // ROTAS PROTEGIDAS
      // ====================
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/enviar-peticao',
        name: 'send_petition',
        builder: (context, state) => const SendPetitionPage(),
      ),
      GoRoute(
        path: '/carregando-precedentes',
        name: 'loading_precedents',
        builder: (context, state) => const LoadingPrecedentsPage(),
      ),
      GoRoute(
        path: '/resultados-precedentes',
        name: 'precedents_results',
        builder: (context, state) => const PrecedentsResultsPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/enviar-peticao-texto',
        name: 'send_petition_text',
        builder: (context, state) => const SendPetitionTextPage(),
      ),
    ],
  );
}