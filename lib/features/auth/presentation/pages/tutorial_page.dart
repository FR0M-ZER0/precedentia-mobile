import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Estrutura de dados das telas do tutorial
  final List<Map<String, dynamic>> _tutorialData = [
    {
      "icon": Icons.balance_outlined,
      "title": "Bem-vindo ao PrecedentIA",
      "description":
          "A inteligência artificial que revoluciona a forma como você encontra jurisprudências e precedentes jurídicos.",
    },
    {
      "icon": Icons.upload_file_outlined,
      "title": "Envie sua Petição",
      "description":
          "Faça o upload do seu documento em PDF ou digite os dados fundamentais para iniciar a análise.",
    },
    {
      "icon": Icons
          .smart_toy_outlined, // Substituir pelo seu robô do Figma futuramente
      "title": "Análise Inteligente",
      "description":
          "Nossa IA cruza seus dados com milhares de decisões dos tribunais e entrega os resultados mais prováveis em segundos.",
    },
  ];

  final _storage = const FlutterSecureStorage();

  // Função centralizada para finalizar o tutorial e salvar no cache
  Future<void> _finishTutorial() async {
    // Grava permanentemente que o usuário já viu o tutorial
    await _storage.write(key: 'hasSeenTutorial', value: 'true');

    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _tutorialData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Se for a última página, finaliza e salva
      _finishTutorial();
    }
  }

  void _skipTutorial() {
    // Pula, finaliza e salva
    _finishTutorial();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.mainWhiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Botão "Pular" no topo
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipTutorial,
                child: Text(
                  'Pular',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.altDarkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Carrossel de Telas (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _tutorialData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone / Imagem (Substituir por Image.asset do Figma se necessário)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.altLightColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _tutorialData[index]["icon"],
                            size: 100,
                            color: AppColors.mainDarkColor,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Título
                        Text(
                          _tutorialData[index]["title"],
                          style: textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Descrição
                        Text(
                          _tutorialData[index]["description"],
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.altDarkColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Rodapé com Indicadores (Dots) e Botão
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicadores (Dots)
                  Row(
                    children: List.generate(
                      _tutorialData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.mainDarkColor
                              : AppColors.altLightColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Botão Próximo / Começar
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDarkColor,
                      foregroundColor: AppColors.mainWhiteColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentPage == _tutorialData.length - 1
                          ? "Começar"
                          : "Próximo",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
