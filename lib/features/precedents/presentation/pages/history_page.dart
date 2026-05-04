import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/base_template.dart';
// ATENÇÃO: Ajuste este import para o caminho correto do seu model
import '../../data/models/precedent_model.dart'; 

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Histórico de pesquisas',
      subtitle: 'Acesse rapidamente as petições e precedentes visualizados anteriormente',
      // Se não quiser botão de voltar (já que acessamos pelo Menu Drawer), pode comentar a linha abaixo:
      // onBackPress: () => context.pop(), 
      body: ValueListenableBuilder(
        // Oculta a necessidade de usar setState. Sempre que o Hive mudar, a tela reconstrói.
        valueListenable: Hive.box<PrecedentModel>('accessed_precedents').listenable(),
        builder: (context, Box<PrecedentModel> box, _) {
          
          if (box.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'Nenhuma pesquisa realizada ainda.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.altDarkColor),
                ),
              ),
            );
          }

          // Transforma o conteúdo da box numa lista e ordena pela data mais recente
          final historyList = box.values.toList();
          historyList.sort((a, b) => b.dataAcesso.compareTo(a.dataAcesso));

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // O scroll fica por conta do BasePageTemplate
            itemCount: historyList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = historyList[index];
              final date = item.dataAcesso;
              // Formatação simples de data: DD/MM/YYYY
              final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

              return Container(
                height: 88, // Altura baseada na proporção do Figma
                decoration: BoxDecoration(
                  color: AppColors.altLightColor.withValues(alpha: 0.3), // Fundo bem clarinho pro lado direito
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    // LADO ESQUERDO (Escuro com Ícone)
                    Container(
                      width: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.mainDarkColor,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined, 
                            color: AppColors.mainWhiteColor,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'file.pdf',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.mainWhiteColor, 
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // LADO DIREITO (Detalhes / Texto)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.titulo, // Puxa o título salvo no Hive
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainDarkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate, // Data formatada
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.altDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}