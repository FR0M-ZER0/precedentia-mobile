import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';
import '../../data/datasource/sentence_remote_datasource.dart';
import '../../data/repositories/sentence_repository_impl.dart';
import '../../domain/usecases/extract_sentence_usecase.dart';

class SentenceAssistantPage extends StatefulWidget {
  const SentenceAssistantPage({super.key});

  @override
  State<SentenceAssistantPage> createState() => _SentenceAssistantPageState();
}

class _SentenceAssistantPageState extends State<SentenceAssistantPage> {
  bool _isUploading = false;

  late final ExtractSentenceUseCase _extractSentenceUseCase =
      ExtractSentenceUseCase(
        SentenceRepositoryImpl(SentenceRemoteDatasourceImpl()),
      );

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        withReadStream: false,
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.path == null && file.bytes == null) {
        _showError('Não foi possível obter os dados do arquivo.');
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

      final userId = await SecureStorageService.readUserId();
      if (userId == null) return;

      final stream = _extractSentenceUseCase(file, userId);

      if (!mounted) return;
      context.push('/analysis-process', extra: stream);
    } catch (e) {
      debugPrint('Erro ao enviar processo: $e');
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

  Widget _buildIllustration() {
    return Center(
      child: Image.asset(
        'assets/images/sentence_assistant.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: 80,
                color: AppColors.mainDarkColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Imagem não encontrada',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mainDarkColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Assistente de sentença',
      subtitle:
          'Envie o arquivo PDF do processo jurídico e gere a minuta da decisão',
      onBackPress: () => context.pop(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            SizedBox(height: 300, child: _buildIllustration()),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.altLightColor,
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: AppColors.altLightColor.withValues(
                    alpha: 0.6,
                  ),
                ),
                icon: _isUploading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.mainDarkColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.upload_outlined, size: 24),
                label: Text(
                  _isUploading ? 'Enviando...' : 'Enviar arquivo',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainDarkColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
