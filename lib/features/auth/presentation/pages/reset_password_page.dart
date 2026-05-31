import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/auth_remote_datasource.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _authRemoteDataSource = AuthRemoteDataSource();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _isLoading = false;

  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = (GoRouterState.of(context).extra as String?) ?? '';
  }

  Future<void> _saveNewPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Volte para solicitar o código de recuperação novamente.',
          ),
          backgroundColor: AppColors.detailsColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRemoteDataSource.confirmPasswordReset(
        email: _email,
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso! Faça login.'),
          backgroundColor: AppColors.accentColor,
        ),
      );

      context.go('/login');
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

  InputDecoration _inputDecoration(
    String label,
    bool isObscure,
    VoidCallback toggle,
    TextTheme textTheme,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.mainDarkColor,
      ),
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
          width: 1.5,
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility_off : Icons.visibility,
          color: AppColors.altDarkColor,
        ),
        onPressed: toggle,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  'Criar nova senha',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua nova senha deve ser diferente da senha utilizada anteriormente.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.altDarkColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _email,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.altDarkColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 40),

                // Campo Código
                TextFormField(
                  controller: _codeController,
                  style: textTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Código de verificação',
                    true,
                    () {},
                    textTheme,
                  ).copyWith(suffixIcon: null),
                  validator: (value) {
                    if ((value ?? '').trim().length != 6) {
                      return 'Digite o código de 6 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Nova Senha
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword1,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration(
                    'Nova Senha',
                    _obscurePassword1,
                    () {
                      setState(() => _obscurePassword1 = !_obscurePassword1);
                    },
                    textTheme,
                  ),
                  validator: (value) {
                    if ((value ?? '').length < 8) {
                      return 'Mínimo de 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Confirmar Senha
                TextFormField(
                  obscureText: _obscurePassword2,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration(
                    'Confirmar Nova Senha',
                    _obscurePassword2,
                    () {
                      setState(() => _obscurePassword2 = !_obscurePassword2);
                    },
                    textTheme,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _newPasswordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão Salvar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveNewPassword,
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
                            'Redefinir Senha',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
