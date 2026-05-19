import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:precedentia_mobile/core/auth/auth_session.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import '../../../petitions/data/models/petition_model.dart';
import '../widgets/history_card.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mainDarkColor,
              onPrimary: Colors.white,
              onSurface: AppColors.mainDarkColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _openPdf(String path) async {
    await OpenFilex.open(path);
  }

  List<PetitionModel> _filteredPetitions(List<PetitionModel> all) {
    if (selectedDate == null) return all;
    return all.where((p) {
      final d = p.sentAt;
      return d.year == selectedDate!.year &&
          d.month == selectedDate!.month &&
          d.day == selectedDate!.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: "",
      onBackPress: () => context.go('/'),
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
            _buildPrefItem(
              'Sair',
              isError: true,
              onTap: () async {
                await AuthSession.instance.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),

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
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Filtrar data',
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
                        if (selectedDate != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => selectedDate = null),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.altDarkColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de Petições do Hive
            ValueListenableBuilder(
              valueListenable: Hive.box<PetitionModel>(
                'petitions',
              ).listenable(),
              builder: (context, Box<PetitionModel> box, _) {
                final all = box.values.toList()
                  ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
                final petitions = _filteredPetitions(all);

                if (petitions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Nenhuma petição encontrada.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: petitions
                      .map(
                        (petition) => HistoryCard(
                          title: petition.name,
                          fileName: DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(petition.sentAt),
                          onTap: () => _openPdf(petition.filePath),
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefItem(
    String label, {
    bool isError = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isError ? AppColors.error : AppColors.mainDarkColor,
          ),
        ),
      ),
    );
  }
}
