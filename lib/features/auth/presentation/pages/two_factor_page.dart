import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Função para processar a mudança em cada campo do código
  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();

    if (code.length == 6) {
      // Feedback de Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código verificado com sucesso!'),
          backgroundColor: AppColors.accentColor,
        ),
      );

      // Simula a conclusão da autenticação
      Future.delayed(const Duration(seconds: 1), () {
        AppRouter.authNotifier.value = true; // Redireciona para a Home
      });
    } else {
      // Feedback de Erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código completo de 6 dígitos.'),
          backgroundColor: AppColors.detailsColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.mainWhiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainDarkColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOGÓTIPO CENTRALIZADO
              Center(
                child: RichText(
                  text: TextSpan(
                    style: textTheme.titleLarge?.copyWith(fontSize: 32),
                    children: const [
                      TextSpan(
                        text: 'Precedent',
                        style: TextStyle(color: AppColors.mainDarkColor),
                      ),
                      TextSpan(
                        text: 'IA',
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'Verificação de Segurança',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Introduza o código de 6 dígitos enviado para o seu e-mail.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.altDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // CAMPOS DO CÓDIGO (6 DÍGITOS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.mainDarkColor,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.altLightColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.mainDarkColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // BOTÃO DE VERIFICAÇÃO
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainDarkColor,
                    foregroundColor: AppColors.mainWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Verificar Código',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // REENVIAR CÓDIGO
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Novo código enviado!')),
                  );
                },
                child: Text(
                  'Não recebeu o código? Reenviar',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mainDarkColor,
                    fontWeight: FontWeight.bold,
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
