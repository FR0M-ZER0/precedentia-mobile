import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart'; // Ajuste o caminho se necessário
import '../../../../core/widgets/nav_bar.dart'; // Ajuste o caminho se necessário

class LoadingPrecedentsPage extends StatefulWidget {
  const LoadingPrecedentsPage({super.key});

  @override
  State<LoadingPrecedentsPage> createState() => _LoadingPrecedentsPageState();
}

class _LoadingPrecedentsPageState extends State<LoadingPrecedentsPage> {
  double _progress = 0.0;
  int _precedentsFound = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoadingSimulation();
  }

  void _startLoadingSimulation() {
    // Simula o carregamento ao longo de ~5 segundos
    const int totalDuration = 5000;
    const int interval = 100;
    int elapsed = 0;

    _timer = Timer.periodic(const Duration(milliseconds: interval), (timer) {
      setState(() {
        elapsed += interval;
        _progress = elapsed / totalDuration;

        // Simula encontrando alguns precedentes de forma aleatória/progressiva
        if (elapsed % 800 == 0) {
          _precedentsFound += 2;
        }
      });

      if (elapsed >= totalDuration) {
        timer.cancel();
        _onLoadingComplete();
      }
    });
  }

  void _onLoadingComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_precedentsFound precedentes encontrados!'),
        backgroundColor: AppColors.accentColor,
      ),
    );

    // Substitui a tela de loading pela tela de resultados
    context.replace('/resultados-precedentes');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.mainWhiteColor,
      appBar: const NavBar(), // Mantendo sua NavBar padrão
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ILUSTRAÇÃO DO ROBÔ
              // TODO: Substitua pelo Image.asset correto após exportar do Figma
              const Icon(
                Icons.smart_toy_outlined,
                size: 120,
                color: AppColors.mainDarkColor,
              ),
              const SizedBox(height: 32),

              // TÍTULO
              Text(
                'Procurando precedentes',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // CONTADOR DE PRECEDENTES
              Text(
                'Precedentes encontrados: $_precedentsFound',
                style: textTheme.labelSmall, // IBM Plex Sans 14px Cinza
              ),
              const SizedBox(height: 16),

              // BARRA DE PROGRESSO CUSTOMIZADA COM GRADIENTE
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.altLightColor, // Fundo azul claro
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
                              AppColors.detailsColor, // Vermelho/Coral
                              AppColors.mainDarkColor, // Azul Escuro
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
