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
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry bodyPadding;

  const BasePageTemplate({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.detailText,
    this.onBackPress,
    this.floatingActionButton,
    this.bodyPadding = const EdgeInsets.only(
      left: 15,
      right: 15,
      top: 0,
      bottom: 30,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const CustomDrawer(),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 30,
                      bottom: 0,
                    ),
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
                      ],
                    ),
                  ),

                  Padding(padding: bodyPadding, child: body),
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
