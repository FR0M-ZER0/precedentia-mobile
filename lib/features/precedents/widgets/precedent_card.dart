import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Precisa adicionar 'intl' no pubspec.yaml
import 'package:precedentia_mobile/features/precedents/domain/entities/precedent.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';

class PrecedentCard extends StatelessWidget {
  final Precedent precedent;
  final VoidCallback onTap;

  const PrecedentCard({
    super.key,
    required this.precedent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          // Garante que as duas colunas tenham a mesma altura
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Bloco Azul da Esquerda (Tribunal) ---
              Container(
                width: 110, // Largura aproximada do Figma
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors
                      .backgroundBlueCard, // Crie esta cor no AppColors (ex: Color(0xFFE1E7F1))
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      precedent.court,
                      style: textTheme.bodySmall,
                    ), // IBM Plex 10px
                    const SizedBox(height: 4),
                    Text(
                      precedent.courtAcronym,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Merriweather 24px Bold
                    // Linha escura grossa
                    const Divider(
                      color: AppColors.primaryColor,
                      thickness: 3,
                      height: 16,
                    ),
                    const Spacer(), // Empurra a data para o final
                    Text(
                      DateFormat('dd/MM/yyyy').format(precedent.creationDate),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // --- 2. Bloco Branco da Direita (Detalhes) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Precedente ${precedent.id}",
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        precedent.subject,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ), // IBM Plex 16px Bold
                      const SizedBox(height: 8),
                      // Texto resumido truncado em 4 linhas
                      Text(
                        precedent.summary,
                        style: textTheme.bodySmall, // IBM Plex 10px
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis, // Trunca o texto
                      ),
                      const Spacer(), // Empurra a compatibilidade para o final
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _getCompatibilityText(precedent.compatibility),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getCompatibilityColor(
                              precedent.compatibility,
                            ),
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
      ),
    );
  }

  // Métodos auxiliares para cor e texto da compatibilidade
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

  Color _getCompatibilityColor(Compatibility comp) {
    switch (comp) {
      case Compatibility.muitoProvavel:
        return AppColors.successColor; // Crie estas cores (Verde)
      case Compatibility.provavel:
        return AppColors.successColor; // Verde
      case Compatibility.poucoProvavel:
        return AppColors.warningColor; // Amarelo/Laranja (Imagem 7)
    }
  }
}
