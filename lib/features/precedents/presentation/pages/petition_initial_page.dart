import 'package:flutter/material.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';

class PetitionInitialPage extends StatelessWidget {
  const PetitionInitialPage({super.key});

  Widget _detailRow({
    required String label,
    required String value,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mainDarkColor,
              ),
            ),
            TextSpan(
              text: value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.mainDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'file.pdf',
      subtitle: 'Enviado no dia 12/03/2035',
      onBackPress: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _detailRow(label: 'Tribunal', value: 'TJSP', textTheme: textTheme),
          _detailRow(
            label: 'Tipo de ação',
            value: 'Indenização por danos morais',
            textTheme: textTheme,
          ),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus rutrum, leo id fermentum fermentum, augue lectus placerat ligula, a ornare eros odio sed ex. Etiam consequat pretium mollis. Sed felis purus, ultricies in maximus nec, placerat at diam. Quisque diam dui, fermentum vel sapien a, mattis tincidunt dui. Cras eleifend lobortis elit, et euismod lacus mattis a.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.altDarkColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Precedentes relacionados',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          PrecedentResultCard(
            tribunal: 'Superior Tribunal de Justiça',
            siglaTribunal: 'STJ',
            codigoPrecedente: 'Precedente abc123',
            situacao: '',
            descricao:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula.',
            species: 'Herança familiar',
            lastUpdate: '01/02/2035',
            probabilidade: 'Muito provável',
            probabilidadeColor: AppColors.accentColor,
          ),
          const SizedBox(height: 16),
          PrecedentResultCard(
            tribunal: 'Supremo Tribunal Federal',
            siglaTribunal: 'STF',
            codigoPrecedente: 'Precedente xyz678',
            situacao: '',
            descricao:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula.',
            species: 'Danos morais',
            lastUpdate: '01/02/2035',
            probabilidade: 'Provável',
            probabilidadeColor: AppColors.detailsColor,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
