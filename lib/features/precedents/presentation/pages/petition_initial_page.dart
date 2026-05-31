import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/analysis/data/models/analysis_model.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart';

class PetitionInitialPage extends StatelessWidget {
  const PetitionInitialPage({super.key, required this.analysis});

  final AnalysisModel analysis;

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

  String _applicabilityLabel(String applicability) {
    switch (applicability) {
      case 'applicable':
        return 'Muito provável';
      case 'low_applicability':
        return 'Baixa aplicabilidade';
      default:
        return applicability;
    }
  }

  Color _applicabilityColor(String applicability) {
    switch (applicability) {
      case 'applicable':
        return AppColors.accentColor;
      case 'low_applicability':
        return AppColors.detailsColor;
      default:
        return AppColors.altDarkColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat('dd/MM/yyyy').format(analysis.createdAt);

    final applicablePrecedents = analysis.precedents
        .where((p) => p.applicability == 'applicable')
        .toList();

    final otherPrecedents = analysis.precedents
        .where((p) => p.applicability != 'applicable')
        .toList();

    final orderedPrecedents = [...applicablePrecedents, ...otherPrecedents];

    return BasePageTemplate(
      title: analysis.type,
      subtitle: 'Enviado em $formattedDate',
      onBackPress: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          if (analysis.tribunal != null)
            _detailRow(
              label: 'Tribunal',
              value: analysis.tribunal!,
              textTheme: textTheme,
            ),
          _detailRow(
            label: 'Tipo de ação',
            value: analysis.type,
            textTheme: textTheme,
          ),
          Text(
            analysis.facts,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.altDarkColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pedidos',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            analysis.requests,
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
          if (orderedPrecedents.isEmpty)
            Text(
              'Nenhum precedente encontrado.',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...orderedPrecedents.map(
              (precedent) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PrecedentResultCard(
                  tribunal: precedent.name,
                  siglaTribunal: precedent.tribunal ?? '-',
                  codigoPrecedente: precedent.species,
                  situacao: precedent.situation,
                  descricao: precedent.summary,
                  species: precedent.species,
                  lastUpdate: precedent.lastUpdate,
                  probabilidade: _applicabilityLabel(precedent.applicability),
                  probabilidadeColor: _applicabilityColor(precedent.applicability),
                ),
              ),
            ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
