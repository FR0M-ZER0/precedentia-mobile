import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'footer.dart';
import 'drawer.dart';

class BasePageTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? detailText;
  final VoidCallback? onBackPress;
  final Widget body;

  const BasePageTemplate({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.detailText,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    // Acessa as definições que você criou no AppTheme
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão Voltar Dinâmico
                  if (onBackPress != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: onBackPress,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 16,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Voltar',
                              // Usa o estilo bodySmall do seu AppTheme (IBM Plex Sans 12px)
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Título Principal
                  Text(
                    title,
                    // Usa o titleMedium do seu AppTheme (Merriweather 28px Bold)
                    style: textTheme.titleMedium,
                  ),

                  // Subtítulo e Detalhe
                  if (subtitle != null || detailText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (subtitle != null)
                            Expanded(
                              child: Text(
                                subtitle!,
                                // Usa o titleSmall (IBM Plex Sans 16px)
                                style: textTheme.titleSmall,
                              ),
                            ),
                          if (detailText != null)
                            Text(
                              detailText!,
                              // Usa o bodySmall (IBM Plex Sans 12px)
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),

                  // Conteúdo customizável da página
                  body,
                ],
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}
