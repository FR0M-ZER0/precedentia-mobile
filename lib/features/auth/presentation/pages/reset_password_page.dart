import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  void _saveNewPassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso! Faça login.'),
          backgroundColor: AppColors.accentColor,
        ),
      );

      // Volta direto para a tela de Login
      context.go('/login');
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
    _passwordController.dispose();
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
                const SizedBox(height: 40),

                // Campo Nova Senha
                TextFormField(
                  controller: _passwordController,
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
                  validator: (value) => value == null || value.length < 6
                      ? 'Mínimo de 6 caracteres'
                      : null,
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
                    if (value != _passwordController.text) {
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
                    onPressed: _saveNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDarkColor,
                      foregroundColor: AppColors.mainWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
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
