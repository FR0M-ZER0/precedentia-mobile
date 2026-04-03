import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';
import '../../data/datasource/petition_remote_datasource.dart';
import '../../data/repositories/petition_repository_impl.dart';
import '../../domain/usecases/extract_petition_usecase.dart';

class SendPetitionPage extends StatefulWidget {
  const SendPetitionPage({super.key});

  @override
  State<SendPetitionPage> createState() => _SendPetitionPageState();
}

class _SendPetitionPageState extends State<SendPetitionPage> {
  bool _isUploading = false;

  late final ExtractPetitionUseCase _extractPetitionUseCase =
      ExtractPetitionUseCase(
        PetitionRepositoryImpl(PetitionRemoteDatasourceImpl()),
      );

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result == null) return;

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        _showError('Não foi possível obter o caminho do arquivo.');
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arquivo "${file.name}" anexado. Enviando...'),
          backgroundColor: AppColors.accentColor,
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() => _isUploading = true);

      final future = _extractPetitionUseCase(filePath);

      if (!mounted) return;
      context.push('/carregando-precedentes', extra: future);
    } catch (e) {
      debugPrint('Erro ao enviar petição: $e');
      if (!mounted) return;
      _showError('Erro ao enviar o arquivo. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.detailsColor),
    );
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
                  onPressed: _isUploading ? null : _pickPDF,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_outlined, size: 24),
                  label: Text(_isUploading ? 'Enviando...' : 'Enviar arquivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.altLightColor,
                    foregroundColor: AppColors.altDarkColor,
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
