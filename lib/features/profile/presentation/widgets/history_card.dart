// lib/features/profile/presentation/widgets/history_card.dart
import 'package:flutter/material.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String fileName;

  const HistoryCard({super.key, required this.title, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 90, // Aumentei um pouco a altura total
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.altLightColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Bloco escuro MAIOR
          Container(
            width: 85, // Aumentado conforme solicitado
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.mainDarkColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: Colors.white,
                size: 32, // Ícone um pouco maior para acompanhar o bloco
              ),
            ),
          ),
          // Informações
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(fileName, style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
