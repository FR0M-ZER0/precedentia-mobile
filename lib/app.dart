import 'package:flutter/material.dart';
import 'package:precedentia_mobile/core/rrouter/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PrecedentIA App',
      routerConfig: AppRouter.router,
    );
  }
}
