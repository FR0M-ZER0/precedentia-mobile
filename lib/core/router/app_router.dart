import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/home_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/loading_precedents_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_text_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
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
        path: '/enviar-peticao-texto',
        name: 'send_petition_text',
        builder: (context, state) => const SendPetitionTextPage(),
      ),
    ],
  );
}