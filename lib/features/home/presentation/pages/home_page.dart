import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Como deseja enviar a petição?",
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(
                  Icons.upload_file,
                  color: colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  "Enviar arquivo PDF",
                  style: textTheme.headlineMedium,
                ),
                subtitle: Text(
                  "Faça o upload do documento em .pdf",
                  style: textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.push('/enviar-peticao');
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: Icon(
                  Icons.edit_document,
                  color: colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  "Digitar dados manualmente",
                  style: textTheme.headlineMedium,
                ),
                subtitle: Text(
                  "Preencha os campos de texto no aplicativo",
                  style: textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.push('/enviar-peticao-texto');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos a altura total da tela
    final screenHeight = MediaQuery.of(context).size.height;

    // Descontamos um valor aproximado do seu cabeçalho (BasePageTemplate + AppBar)
    // E dividimos o espaço que sobra por 3.
    // O .clamp() garante que o botão nunca fique menor que 120 pixels para não espremer o GIF.
    final double cardHeight = ((screenHeight - 250) / 3).clamp(120.0, 300.0);

    return BasePageTemplate(
      title: "O que deseja fazer hoje?",
      subtitle: "Escolha um dos modos",
      bodyPadding: const EdgeInsets.symmetric(horizontal: 0),
      body: Column(
        children: [
          // 1º Botão: Pesquisa (GIF Direita, Texto Esquerda)
          Container(height: 1, color: AppColors.altDarkColor),
          SizedBox(
            height: cardHeight,
            child: _ActionGifCard(
              title: "Pesquisa de\nprecedentes",
              gifPath: "assets/images/pesquisa.gif",
              imageAlignment: Alignment.bottomRight,
              textAlign: TextAlign.left,
              cardHeight: cardHeight,
              onTap: () => _showSelectionModal(context),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),

          // 2º Botão: Assistente de sentença (GIF Esquerda, Texto Direita)
          Container(height: 1, color: AppColors.altDarkColor),
          SizedBox(
            height: cardHeight,
            child: _ActionGifCard(
              title: "Assistente de\nsentença",
              gifPath: "assets/images/assistente.gif",
              imageAlignment: Alignment.bottomLeft,
              textAlign: TextAlign.right,
              cardHeight: cardHeight,
              onTap: () => context.push('/assistente-sentenca'),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),

          // 3º Botão: Geração de petição (GIF Direita, Texto Esquerda)
          Container(height: 1, color: AppColors.altDarkColor),
          SizedBox(
            height: cardHeight,
            child: _ActionGifCard(
              title: "Geração de\npetição inicial",
              gifPath: "assets/images/geracao.gif",
              imageAlignment: Alignment.bottomRight,
              textAlign: TextAlign.left,
              cardHeight: cardHeight,
              onTap: () => context.push('/gerar-peticao-form'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGifCard extends StatelessWidget {
  final String title;
  final String gifPath;
  final Alignment imageAlignment;
  final TextAlign textAlign;
  final double cardHeight;
  final VoidCallback onTap;

  const _ActionGifCard({
    required this.title,
    required this.gifPath,
    required this.imageAlignment,
    required this.textAlign,
    required this.cardHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLeftAligned = textAlign == TextAlign.left;

    final gifHeight = cardHeight * 0.65;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.altLightColor,
        child: Stack(
          children: [
            // Imagem/GIF
            Align(
              alignment: imageAlignment,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Image.asset(
                  gifPath,
                  height: gifHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: gifHeight,
                    width: gifHeight,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.gif_box,
                      size: 40,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),

            // Texto do botão
            Align(
              alignment: isLeftAligned ? Alignment.topLeft : Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    fontSize: cardHeight < 140 ? 18 : 22,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
