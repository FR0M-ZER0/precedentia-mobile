import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class SendPetitionPage extends StatefulWidget {
  const SendPetitionPage({super.key});

  @override
  State<SendPetitionPage> createState() => _SendPetitionPageState();
}

class _SendPetitionPageState extends State<SendPetitionPage> {
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = result.files.first;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo "${file.name}" anexado com sucesso!'),
            backgroundColor: AppColors.accentColor,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          context.push('/carregando-precedentes');
        });
      } else {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao selecionar o arquivo. Tente novamente.'),
          backgroundColor: AppColors.detailsColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePageTemplate(
      title: 'Envie a petição inicial',
      subtitle: 'Envie o arquivo da petição inicial no formato .pdf',
      onBackPress: () => Navigator.pop(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/plane.png', width: 320, height: 320),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _pickPDF,
                  icon: const Icon(Icons.upload_outlined, size: 24),
                  label: const Text('Enviar arquivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.altLightColor,
                    foregroundColor: AppColors.mainDarkColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
