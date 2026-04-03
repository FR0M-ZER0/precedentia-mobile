import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';

class SearchManualPage extends StatelessWidget {
  const SearchManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePageTemplate(
      title: "Envie dados da petição inicial", // Texto do Figma (Imagem 6)
      subtitle: "Escreva os dados da petição inicial nos campos abaixo",
      onBackPress: () => context.pop(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(
              Icons.edit_note,
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            Text(
              "TEMPORÁRIO - TELA DE DIGITAÇÃO MANUAL",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
