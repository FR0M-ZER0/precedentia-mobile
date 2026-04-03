import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class PrecedentsResultsPage extends StatelessWidget {
  const PrecedentsResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePageTemplate(
      title: 'Precedentes jurídicos',
      onBackPress: () => context.go('/enviar-peticao'),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bool isPoucoProvavel = index == 3;

          return PrecedentResultCard(
            tribunal: 'Superior Tribunal de Justiça',
            siglaTribunal: 'STJ',
            data: '01/02/2035',
            codigoPrecedente: 'Precedente abc123',
            titulo: 'Herança familiar',
            descricao:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula. Lorem ipsum dolor sit amet, consectetur...',
            probabilidade: isPoucoProvavel
                ? 'Pouco provável'
                : 'Muito provável',
            isAltaProbabilidade: !isPoucoProvavel,
          );
        },
      ),
    );
  }
}

class PrecedentResultCard extends StatelessWidget {
  final String tribunal;
  final String siglaTribunal;
  final String data;
  final String codigoPrecedente;
  final String titulo;
  final String descricao;
  final String probabilidade;
  final bool isAltaProbabilidade;

  const PrecedentResultCard({
    super.key,
    required this.tribunal,
    required this.siglaTribunal,
    required this.data,
    required this.codigoPrecedente,
    required this.titulo,
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
              color: AppColors.altLightColor, // Fundo azul claro
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
                    data,
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
                    const SizedBox(height: 4),
                    Text(
                      titulo,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
