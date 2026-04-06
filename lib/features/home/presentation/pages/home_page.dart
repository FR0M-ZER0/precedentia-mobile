import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Função que exibe o modal de escolha ao clicar no botão
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
            mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
            children: [
              Text(
                "Como deseja enviar a petição?",
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Opção 1: Arquivo PDF
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
                  Navigator.pop(bottomSheetContext); // Fecha o modal
                  context.push('/enviar-peticao'); // Vai para a tela de PDF
                },
              ),

              const Divider(height: 32),

              // Opção 2: Inserção de Texto
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
                  Navigator.pop(bottomSheetContext); // Fecha o modal
                  context.push(
                    '/enviar-peticao-texto',
                  ); // Vai para a tela de Texto
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
    return BasePageTemplate(
      title: "Procure precedentes",
      subtitle: "Aqui você pode iniciar sua busca jurídica ou enviar uma nova petição.",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),

          // Botão que agora abre o modal de seleção
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _showSelectionModal(context),
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
