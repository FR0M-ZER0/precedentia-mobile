import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/features/home/presentation/pages/home_page.dart';
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
    ],
  );
}
