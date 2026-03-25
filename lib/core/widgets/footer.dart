import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessando as definições globais do seu AppTheme
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      // Usa a cor principal definida no seu tema (mainDarkColor)
      color: colorScheme.primary,
      child: SafeArea(
        top: false,
        child: Center(
          child: RichText(
            text: TextSpan(
              // Baseia-se no bodySmall do seu tema (IBM Plex Sans)
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10, // Ajuste fino para o rodapé
                color: Colors.white54,
              ),
              children: [
                const TextSpan(text: 'Desenvolvido por '),
                TextSpan(
                  text: 'From Zero_',
                  style: TextStyle(
                    // Usa a cor secundária do seu tema (accentColor)
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
