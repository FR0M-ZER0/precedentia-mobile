// lib/features/profile/presentation/pages/user_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import '../widgets/history_card.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  DateTime selectedDate = DateTime(2035, 4, 13);

  // Função para abrir o DatePicker do Flutter
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mainDarkColor, // Cor do cabeçalho do picker
              onPrimary: Colors.white,
              onSurface: AppColors.mainDarkColor, // Cor dos dias
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: "",
      onBackPress: () => context.pop(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.altLightColor,
                    child: Icon(
                      Icons.person_outline,
                      size: 55,
                      color: AppColors.mainDarkColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Fulano da Silva", style: textTheme.titleMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("fulano@email.com", style: textTheme.titleSmall),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.altDarkColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Preferências
            Text(
              "Preferências",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPrefItem("Tema do aplicativo"),
            _buildPrefItem("Alterar senha"),
            _buildPrefItem("Sair", isError: true),

            const SizedBox(height: 40),

            // Cabeçalho da Lista com DatePicker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Petições iniciais",
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Campo de Data clicável
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.altLightColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.calendar_month,
                          size: 14,
                          color: AppColors.altDarkColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de Cards
            const HistoryCard(title: "Assunto XYZ", fileName: "file.pdf"),
            const HistoryCard(title: "Assunto XYZ", fileName: "file.pdf"),
            const HistoryCard(title: "Assunto XYZ", fileName: "file.pdf"),
            const HistoryCard(title: "Assunto XYZ", fileName: "file.pdf"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefItem(String label, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isError ? AppColors.error : AppColors.mainDarkColor,
        ),
      ),
    );
  }
}
