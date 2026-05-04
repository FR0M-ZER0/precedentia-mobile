import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrecedentDetailPage extends StatefulWidget {
  final String precedentId;
  final Map<String, dynamic> data;

  const PrecedentDetailPage({
    super.key,
    required this.precedentId,
    required this.data,
  });

  @override
  State<PrecedentDetailPage> createState() => _PrecedentDetailPageState();
}

class _PrecedentDetailPageState extends State<PrecedentDetailPage> {
  bool _isExpanded = false;

  // String _nomeTribunal(String sigla) {
  //   const nomes = {
  //     'STF': 'Supremo Tribunal Federal',
  //     'STJ': 'Superior Tribunal de Justiça',
  //     'STM': 'Superior Tribunal Militar',
  //     'TST': 'Tribunal Superior do Trabalho',
  //     'TRF1': 'Tribunal Regional Federal 1ª Região',
  //     'TRF2': 'Tribunal Regional Federal 2ª Região',
  //     'TRF3': 'Tribunal Regional Federal 3ª Região',
  //     'TRF4': 'Tribunal Regional Federal 4ª Região',
  //     'TRF5': 'Tribunal Regional Federal 5ª Região',
  //   };
  //   return nomes[sigla] ?? sigla;
  // }

  // MUDANÇA: agora recebe String applicability em vez de Compatibility enum
  String _getCompatibilityText(String applicability) {
    switch (applicability) {
      case 'applicable':
        return 'Aplicável';
      case 'possible_applicability':
        return 'Possivelmente aplicável';
      case 'low_applicability':
        return 'Pouco aplicável';
      default:
        return 'Não aplicável';
    }
  }

  Color _getCompatibilityColor(String applicability) {
    switch (applicability) {
      case 'applicable':
        return AppColors.accentColor;
      case 'possible_applicability':
        return Colors.green.shade600;
      case 'low_applicability':
        return AppColors.detailsColor;
      default:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final item = widget.data;
    final double score = (item['score'] as num).toDouble();
    final double rawScore = score * 100;
    final double displayScore = rawScore >= 100 ? 99 : rawScore;

    // MUDANÇA: lê applicability direto do item
    final String applicability = (item['applicability'] as String?) ?? '';
    final compatibilityColor = _getCompatibilityColor(applicability);

    Future<void> openUrl(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    final String name = item['name'] as String;
    final String courtAcronym = item['tribunal'] as String;
    // final String court = _nomeTribunal(courtAcronym);
    final String description = item['description'] as String;
    final String summary = (item['summary'] as String?) ?? '';
    final String question = (item['question'] as String?) ?? '';
    final String species = item['species'] as String;
    final String situation = item['situation'] as String;
    final String lastUpdate = (item['last_update'] as String?) ?? '';
    final String url = item['url'] as String;

    return BasePageTemplate(
      title: name,
      onBackPress: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/precedents');
        }
      },
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Situação: $situation",
                  style: textTheme.headlineMedium,
                ),
                if (lastUpdate.isNotEmpty)
                  Text(lastUpdate, style: textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Resumo dos fatos",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              description,
              style: textTheme.bodyMedium,
              maxLines: _isExpanded ? null : 5,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isExpanded ? 'Ver menos' : 'Ver tudo',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.altDarkColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (question.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Questão",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(question, style: textTheme.bodyMedium),
            ],

            const SizedBox(height: 32),

            Center(
              child: Column(
                children: [
                  Text(
                    'Compatibilidade',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _InfoBadge(
                            label: 'Similaridade',
                            value: '${displayScore.toInt()}%',
                            icon: Icons.percent_rounded,
                            backgroundColor: compatibilityColor.withValues(
                              alpha: 0.12,
                            ),
                            iconColor: compatibilityColor,
                            valueColor: compatibilityColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoBadge(
                            label: 'Tribunal',
                            value: courtAcronym,
                            icon: Icons.account_balance_rounded,
                            backgroundColor: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF4F6BE8),
                            valueColor: const Color(0xFF4F6BE8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoBadge(
                            label: 'Tipo de precedente',
                            value: species,
                            icon: Icons.gavel_rounded,
                            backgroundColor: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFE07B00),
                            valueColor: const Color(0xFFE07B00),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    _getCompatibilityText(applicability),
                    style: textTheme.titleMedium?.copyWith(
                      color: compatibilityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (summary.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mainDarkColor,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Resumo: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: summary),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => openUrl(url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.altLightColor,
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Visitar link',
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.mainDarkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? valueColor;

  const _InfoBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: iconColor.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.mainDarkColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
