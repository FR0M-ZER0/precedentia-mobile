import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nav_bar.dart';

class LoadingPrecedentsPage extends StatefulWidget {
  final Future<Map<String, dynamic>> extractFuture;
  const LoadingPrecedentsPage({super.key, required this.extractFuture});

  @override
  State<LoadingPrecedentsPage> createState() => _LoadingPrecedentsPageState();
}

class _LoadingPrecedentsPageState extends State<LoadingPrecedentsPage> {
  double _progress = 0.0;
  Timer? _animationTimer;
  bool _requestDone = false;

  @override
  void initState() {
    super.initState();
    _startFakeAnimation();
    _waitForRequest();
  }

  void _startFakeAnimation() {
    const int interval = 100;

    _animationTimer = Timer.periodic(const Duration(milliseconds: interval), (
      timer,
    ) {
      if (!mounted) return;
      setState(() {
        if (!_requestDone && _progress < 0.9) {
          _progress += 0.002;
        }
        if (_requestDone && _progress < 1.0) {
          _progress += 0.05;
        }
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _waitForRequest() async {
    try {
      final response = await widget.extractFuture;

      debugPrint('=== Resposta /documents/extract ===');
      debugPrint('Query: ${response['query']}');
      debugPrint('Total encontrado: ${response['total_found']}');
      debugPrint('Results: ${response['results']}');
      debugPrint('===================================');

      if (!mounted) return;
      setState(() => _requestDone = true);

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      context.replace('/resultados-precedentes');
    } catch (e) {
      debugPrint('Erro ao extrair petição: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao processar a petição. Tente novamente.'),
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.mainWhiteColor,
      appBar: const NavBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smart_toy_outlined,
                size: 120,
                color: AppColors.mainDarkColor,
              ),
              const SizedBox(height: 32),

              Text(
                'Procurando precedentes',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                // 'Precedentes encontrados: $_precedentsFound',
                'Procurando precedentes similares',
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: 16),

              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.altLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: constraints.maxWidth * _progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.detailsColor,
                              AppColors.mainDarkColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
