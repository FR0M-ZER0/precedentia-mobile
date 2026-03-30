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
      
      // DICA: Como a Home é a primeira tela (raiz '/'), não temos para onde "voltar".
      // Remover ou comentar o onBackPress esconde o botão "Voltar" do BasePageTemplate.
      // onBackPress: () => context.pop(), 
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aqui você pode iniciar sua busca jurídica ou enviar uma nova petição.",
            // Usando IBM Plex Sans 16px definido no seu AppTheme
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 30),

          // Botão que agora redireciona para a tela de Envio de Petição
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Navega para a rota que criamos no AppRouter
                context.push('/enviar-peticao');
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