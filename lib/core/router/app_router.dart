import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/home_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/loading_precedents_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/send_petition_text_page.dart';
import 'package:precedentia_mobile/features/search/presentation/pages/search_page.dart';
import 'package:precedentia_mobile/features/upload/presentation/pages/upload_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedent_page.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedent_datails_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),

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
        path: '/precedents',
        builder: (context, state) => const PrecedentListPage(),
      ),
      GoRoute(
        path: '/precedents/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PrecedentDetailPage(
            precedentId: id,
          ); // Agora o erro deve sumir
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
