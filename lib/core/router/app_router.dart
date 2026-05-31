import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/features/analysis/data/models/analysis_model.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/home_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/loading_precedents_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_text_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/initial_petition_edit_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/initial_sentence_edit_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/analysis_process_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/sentence_assistant_page.dart';
import 'package:precedentia_mobile/features/profile/presentation/pages/user_page.dart';
import 'package:precedentia_mobile/features/search/presentation/pages/search_page.dart';
import 'package:precedentia_mobile/features/upload/presentation/pages/upload_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedent_datails_page.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/not_found_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/history_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/petition_initial_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/tutorial_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/two_factor_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:precedentia_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:precedentia_mobile/core/auth/auth_session.dart';

class AppRouter {
  static ValueNotifier<bool> get authNotifier =>
      AuthSession.instance.authNotifier;

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;

      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/cadastro' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/tutorial' ||
          state.matchedLocation == '/2fa' ||
          state.matchedLocation == '/esqueci-senha' ||
          state.matchedLocation == '/redefinir-senha';

      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      return null;
    },

    routes: [
      // ====================
      // ROTAS PÚBLICAS
      // ====================
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
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
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return TwoFactorPage(email: email);
        },
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
        path: '/search/upload',
        name: 'searchUpload',
        builder: (context, state) => const SearchUploadPage(),
      ),

      GoRoute(
        path: '/search/manual',
        name: 'searchManual',
        builder: (context, state) => const SearchManualPage(),
      ),
      GoRoute(
        path: '/precedents/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final item = state.extra as Map<String, dynamic>;
          return PrecedentDetailPage(precedentId: id, data: item);
        },
      ),
      GoRoute(
        path: '/enviar-peticao',
        name: 'send_petition',
        builder: (context, state) => const SendPetitionPage(),
      ),
      GoRoute(
        path: '/carregando-precedentes',
        name: 'loading_precedents',
        builder: (context, state) => LoadingPrecedentsPage(
          extractFuture: state.extra as Future<Map<String, dynamic>>,
        ),
      ),
      GoRoute(
        path: '/resultados-precedentes',
        builder: (context, state) {
          final stream = state.extra as Stream<Map<String, dynamic>>;
          return PrecedentsResultsPage(stream: stream);
        },
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
      GoRoute(
        path: '/peticao-inicial-editar',
        name: 'initial_petition_edit',
        builder: (context, state) => const InitialPetitionEditPage(),
      ),
      GoRoute(
        path: '/sentenca-inicial-editar',
        name: 'initial_sentence_edit',
        builder: (context, state) => const InitialSentenceEditPage(),
      ),
      GoRoute(
        path: '/assistente-sentenca',
        name: 'sentence_assistant',
        builder: (context, state) => const SentenceAssistantPage(),
      ),
      GoRoute(
        path: '/analysis-process',
        name: 'analysis_process',
        builder: (context, state) => AnalysisProcessPage(
          stream: state.extra as Stream<Map<String, dynamic>>,
        ),
      ),
      GoRoute(
        path: '/peticao-inicial',
        name: 'peticao-inicial',
        builder: (context, state) =>
            PetitionInitialPage(analysis: state.extra as AnalysisModel),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserPage(),
      ),
      GoRoute(
        path: '/not-found',
        name: 'not_found',
        builder: (context, state) => const NotFoundPage(),
      ),
    ],
  );
}
