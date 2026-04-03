import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';

class SearchUploadPage extends StatelessWidget {
  const SearchUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o seu template para garantir a consistência visual
    return BasePageTemplate(
      title: "Envie a petição inicial", // Texto do Figma (Imagem 5)
      subtitle: "Envie o arquivo da petição inicial no formato .pdf",
      // O botão "Voltar" funciona automaticamente com context.pop()
      onBackPress: () => context.pop(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(
              Icons.upload_file,
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            Text(
              "TEMPORÁRIO - TELA DE UPLOAD PDF",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
