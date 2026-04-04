import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class PrecedentsResultsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PrecedentsResultsPage({super.key, required this.data});

  String _nomeTribunal(String sigla) {
    const nomes = {
      'STF': 'Supremo Tribunal Federal',
      'STJ': 'Superior Tribunal de Justiça',
      'STM': 'Superior Tribunal Militar',
      'TST': 'Tribunal Superior do Trabalho',
      'TRF1': 'Tribunal Regional Federal 1ª Região',
      'TRF2': 'Tribunal Regional Federal 2ª Região',
      'TRF3': 'Tribunal Regional Federal 3ª Região',
      'TRF4': 'Tribunal Regional Federal 4ª Região',
      'TRF5': 'Tribunal Regional Federal 5ª Região',
    };
    return nomes[sigla] ?? sigla;
  }

  @override
  Widget build(BuildContext context) {
    final results = (data['results'] as List<dynamic>?) ?? [];

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum precedente encontrado.'));
    }

    return BasePageTemplate(
      title: 'Precedentes jurídicos',
      onBackPress: () => context.go('/enviar-peticao'),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = results[index] as Map<String, dynamic>;
          final double score = (item['similarity_score'] as num).toDouble();
          final bool isAltaProbabilidade = score >= 0.55;

          return GestureDetector(
            onTap: () =>
                context.push('/precedents/details/${item['id']}', extra: item),
            child: PrecedentResultCard(
              tribunal: _nomeTribunal(item['tribunal'] as String),
              siglaTribunal: item['tribunal'] as String,
              codigoPrecedente: item['name'] as String,
              descricao: item['description'] as String,
              situacao: item['situation'] as String,
              probabilidade: isAltaProbabilidade
                  ? 'Muito provável'
                  : 'Pouco provável',
              isAltaProbabilidade: isAltaProbabilidade,
            ),
          );
        },
      ),
    );
  }
}

class PrecedentResultCard extends StatelessWidget {
  final String tribunal;
  final String siglaTribunal;
  final String codigoPrecedente;
  final String situacao;
  final String descricao;
  final String probabilidade;
  final bool isAltaProbabilidade;

  const PrecedentResultCard({
    super.key,
    required this.tribunal,
    required this.siglaTribunal,
    required this.codigoPrecedente,
    required this.situacao,
    required this.descricao,
    required this.probabilidade,
    required this.isAltaProbabilidade,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainWhiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 120,
              color: AppColors.altLightColor,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tribunal,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.altDarkColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        siglaTribunal,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainDarkColor,
                        ),
                      ),
                      Container(
                        height: 4,
                        width: double.infinity,
                        color: AppColors.mainDarkColor,
                        margin: const EdgeInsets.only(top: 4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '01/01/2025', // TODO: Adicionar data vindo da API
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.altDarkColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      codigoPrecedente,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descricao,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.altDarkColor,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        probabilidade,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAltaProbabilidade
                              ? AppColors.accentColor
                              : AppColors.detailsColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
