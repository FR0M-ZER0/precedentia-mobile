import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_remote_datasource.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key, required this.email});

  final String email;

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final _authRemoteDataSource = AuthRemoteDataSource();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

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

  Future<void> _verifyCode() async {
    final code = _controllers.map((controller) => controller.text).join();

    if (widget.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Volte ao login para solicitar um novo código.'),
          backgroundColor: AppColors.detailsColor,
        ),
      );
      return;
    }

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código completo de 6 dígitos.'),
          backgroundColor: AppColors.detailsColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final accessToken = await _authRemoteDataSource.verifyTwoFactor(
        email: widget.email,
        code: code,
      );

      await AuthSession.instance.setToken(accessToken);

      if (!mounted) {
        return;
      }

      context.go('/');
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.detailsColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              if (widget.email.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.altDarkColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainDarkColor,
                    foregroundColor: AppColors.mainWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Verificar Código',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // REENVIAR CÓDIGO
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  'Não recebeu o código? Voltar ao login',
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
