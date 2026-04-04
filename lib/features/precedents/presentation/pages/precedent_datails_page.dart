import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/features/precedents/domain/entities/precedent.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final textTheme = Theme.of(context).textTheme;

    // --- MOCK DE DADOS ---
    final item = widget.data;
    final double score = (item['similarity_score'] as num).toDouble();

    final precedent = Precedent(
      id: item['id'].toString(),
      name: item['name'],
      court: _nomeTribunal(item['tribunal'] as String),
      courtAcronym: item['tribunal'] as String,
      creationDate: DateTime(2025, 1, 1), // mockado
      subject: item['name'] as String,
      summary: item['description'] as String,
      score: score * 100, // converte 0.63 → 63%
      compatibility: score >= 0.55
          ? Compatibility.muitoProvavel
          : Compatibility.poucoProvavel,
    );

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
            // Cabeçalho: Tribunal e Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  precedent.court,
                  style: textTheme.headlineMedium, // IBM Plex Sans Medium 16px
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(precedent.creationDate),
                  style: textTheme.bodySmall, // IBM Plex Sans Regular 12px
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Texto do Precedente com Lógica de Expansão
            Text(
              precedent.summary,
              style: textTheme
                  .bodyMedium, // IBM Plex Sans Regular 16px, height 1.875
              maxLines: _isExpanded ? null : 5,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),

            // Botão Ver Tudo
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
                  _isExpanded ? "Ver menos" : "Ver tudo",
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.altDarkColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Seção de Compatibilidade Centralizada
            Center(
              child: Column(
                children: [
                  Text(
                    "Compatibilidade",
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${precedent.score.toInt()}%",
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentColor, // Verde Neon
                    ),
                  ),
                  Text(
                    _getCompatibilityText(precedent.compatibility),
                    style: textTheme.titleMedium, // Merriweather Bold 24px
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Resumo da IA
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mainDarkColor,
                ),
                children: [
                  const TextSpan(
                    text: "Resumo da IA: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: precedent.summary),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botão Visitar Link
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Aqui entrará a lógica de abrir a URL externa
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.altLightColor, // Azulzinho muito claro
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Visitar link",
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

  String _getCompatibilityText(Compatibility comp) {
    switch (comp) {
      case Compatibility.muitoProvavel:
        return "Muito provável";
      case Compatibility.provavel:
        return "Provável";
      case Compatibility.poucoProvavel:
        return "Pouco provável";
    }
  }
}
