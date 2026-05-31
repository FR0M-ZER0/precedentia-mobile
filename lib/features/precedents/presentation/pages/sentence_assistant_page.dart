import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class SentenceAssistantPage extends StatefulWidget {
  const SentenceAssistantPage({super.key});

  @override
  State<SentenceAssistantPage> createState() => _SentenceAssistantPageState();
}

class _SentenceAssistantPageState extends State<SentenceAssistantPage> {
  bool _isLoading = false;

  Future<void> _handleUploadFile() async {
    setState(() {
      _isLoading = true;
    });

    // Simular upload do arquivo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo enviado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

            // ── Ilustração ────────────────────────────────────────
            SizedBox(height: 300, child: _buildIllustration()),

            const SizedBox(height: 32),

            // ── Botão de enviar arquivo ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleUploadFile,
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
                icon: _isLoading
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
                    : const Icon(Icons.share),
                label: Text(
                  _isLoading ? 'Enviando...' : 'Enviar arquivo',
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
