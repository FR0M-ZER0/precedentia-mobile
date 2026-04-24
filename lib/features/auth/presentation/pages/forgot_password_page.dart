import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  void _sendRecoveryEmail() {
    if (_formKey.currentState!.validate()) {
      // Feedback de Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instruções enviadas para o seu e-mail!'),
          backgroundColor: AppColors.accentColor,
        ),
      );

      // Simula o usuário clicando no link do e-mail e indo para a tela de redefinir
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.push('/redefinir-senha');
      });
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
                        TextSpan(text: 'Precedent', style: TextStyle(color: AppColors.mainDarkColor)),
                        TextSpan(text: 'IA', style: TextStyle(color: AppColors.accentColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Esqueceu sua senha?',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Digite o e-mail cadastrado e enviaremos as instruções para você criar uma nova senha.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.altDarkColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo E-mail
                TextFormField(
                  style: textTheme.bodyMedium,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mainDarkColor),
                    filled: true,
                    fillColor: AppColors.altLightColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.mainDarkColor, width: 1.5)),
                  ),
                  validator: (value) => value == null || !value.contains('@') ? 'Insira um e-mail válido' : null,
                ),
                const SizedBox(height: 32),

                // Botão Enviar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sendRecoveryEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDarkColor,
                      foregroundColor: AppColors.mainWhiteColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Enviar Instruções', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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