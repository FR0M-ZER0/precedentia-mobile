import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _saveNewEmail() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail atualizado com sucesso! Faça login novamente.'),
          backgroundColor: AppColors.accentColor,
        ),
      );
      
      // Volta direto para a tela de Login (ou tela de perfil, dependendo da sua regra de negócio)
      context.go('/login');
    }
  }

  InputDecoration _inputDecoration(String label, TextTheme textTheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mainDarkColor),
      filled: true,
      fillColor: AppColors.altLightColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.mainDarkColor, width: 1.5)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                        TextSpan(text: 'Precedent', style: TextStyle(color: AppColors.mainDarkColor)),
                        TextSpan(text: 'IA', style: TextStyle(color: AppColors.accentColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Definir novo e-mail',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Insira o seu novo endereço de e-mail abaixo. Ele será usado para seus próximos acessos.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.altDarkColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo Novo E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration('Novo E-mail', textTheme),
                  validator: (value) => value == null || !value.contains('@') ? 'Insira um e-mail válido' : null,
                ),
                const SizedBox(height: 16),

                // Campo Confirmar E-mail
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration('Confirmar Novo E-mail', textTheme),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirme o novo e-mail';
                    if (value != _emailController.text) return 'Os e-mails não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão Salvar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveNewEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDarkColor,
                      foregroundColor: AppColors.mainWhiteColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Atualizar E-mail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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