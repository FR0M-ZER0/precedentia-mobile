import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessando o textTheme do seu AppTheme para o conteúdo do body
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: "Página Inicial",
      subtitle: "Bem-vindo ao PrecedentIA",
      detailText: "v1.0.0", // Exemplo de uso do campo detalhe
      // O botão "Voltar" só aparece porque passamos a função abaixo
      onBackPress: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aqui você pode iniciar sua busca jurídica ou enviar uma nova petição.",
            // Usando IBM Plex Sans 16px definido no seu AppTheme
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 30),

          // Exemplo de botão seguindo o padrão que o grupo pode usar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Exemplo: context.go('/search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Iniciar Nova Consulta"),
            ),
          ),
        ],
      ),
    );
  }
}
