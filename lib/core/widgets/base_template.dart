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
  // 1. Adicione o parâmetro aqui
  final Widget? floatingActionButton;

  const BasePageTemplate({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.detailText,
    this.onBackPress,
    this.floatingActionButton, // 2. E aqui no construtor
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const CustomDrawer(),
      // 3. Adicione esta linha para o Scaffold renderizar o botão
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Text(title, style: textTheme.titleMedium),

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
                                style: textTheme.titleSmall,
                              ),
                            ),
                          if (detailText != null)
                            Text(detailText!, style: textTheme.bodySmall),
                        ],
                      ),
                    ),

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
