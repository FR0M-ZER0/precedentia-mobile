import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/features/precedents/domain/entities/precedent.dart';
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
  bool _summaryLoaded = false;

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

  String _getCompatibilityText(Compatibility comp) {
    switch (comp) {
      case Compatibility.muitoProvavel:
        return 'Muito provável';
      case Compatibility.provavel:
        return 'Provável';
      case Compatibility.poucoProvavel:
        return 'Pouco provável';
      case Compatibility.muitoPoucoProvavel:
        return 'Muito pouco provável';
    }
  }

  Color _getCompatibilityColor(Compatibility comp) {
    switch (comp) {
      case Compatibility.muitoProvavel:
        return AppColors.accentColor;
      case Compatibility.provavel:
        return Colors.green.shade600;
      case Compatibility.poucoProvavel:
        return AppColors.detailsColor;
      case Compatibility.muitoPoucoProvavel:
        return Colors.red.shade700;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _summaryLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final item = widget.data;
    final double score = (item['score'] as num).toDouble();
    final double rawScore = score * 100;
    final double displayScore = rawScore >= 100 ? 99 : rawScore;

    final compatibility = score >= 0.85
        ? Compatibility.muitoProvavel
        : score >= 0.60
        ? Compatibility.provavel
        : score >= 0.40
        ? Compatibility.poucoProvavel
        : Compatibility.muitoPoucoProvavel;

    final precedent = Precedent(
      id: item['id'].toString(),
      name: item['name'],
      court: _nomeTribunal(item['tribunal'] as String),
      courtAcronym: item['tribunal'] as String,
      creationDate: DateTime(2025, 1, 1),
      subject: item['name'] as String,
      description: item['description'] as String,
      summary: item['summary'] as String,
      species: item['species'] as String,
      situation: item['situation'] as String,
      score: displayScore,
      compatibility: compatibility,
      lastUpdate: item['last_update'] as String,
      url: item['url'] as String,
    );

    final compatibilityColor = _getCompatibilityColor(precedent.compatibility);

    Future<void> openUrl(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return BasePageTemplate(
      title: precedent.name,
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
                  "Situação: ${precedent.situation}",
                  style: textTheme.headlineMedium,
                ),
                Text(precedent.lastUpdate, style: textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Descrição",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              precedent.description,
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
                            value: '${precedent.score.toInt()}%',
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
                            value: precedent.courtAcronym,
                            icon: Icons.account_balance_rounded,
                            backgroundColor: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF4F6BE8),
                            valueColor: const Color(0xFF4F6BE8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoBadge(
                            label: 'Espécie',
                            value: precedent.species,
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
                    _getCompatibilityText(precedent.compatibility),
                    style: textTheme.titleMedium?.copyWith(
                      color: compatibilityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _summaryLoaded
                  ? RichText(
                      key: const ValueKey('summary'),
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mainDarkColor,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Resumo da IA: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: precedent.summary),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('loading'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.altDarkColor,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gerando resumo da IA...',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.altDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => openUrl(precedent.url),
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
        mainAxisSize: MainAxisSize.min,
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
