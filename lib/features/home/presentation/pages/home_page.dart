import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/widgets/speed_dial.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePageTemplate(
      title: "Procure precedentes",
      subtitle:
          "Envie o arquivo da petição inicial ou escreva os campos da pesquisa",
      onBackPress: null, // Oculta o voltar na home
      // Atualizamos o SpeedDialMenu aqui:
      floatingActionButton: SpeedDialMenu(
        // Quando clicar no botão de Texto/Manual:
        onTextPressed: () {
          context.push('/search/manual'); // Navega para a rota manual
        },

        // Quando clicar no botão de Upload:
        onUploadPressed: () {
          context.push('/search/upload'); // Navega para a rota de upload
        },

        // Opcional: ação ao clicar no + principal
        onMainPressed: () {},
      ),

      body: const Column(
        children: [
          // Conteúdo principal da Home
        ],
      ),
    );
  }
}
