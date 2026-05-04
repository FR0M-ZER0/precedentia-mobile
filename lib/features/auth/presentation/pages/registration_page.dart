import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  InputDecoration _authInputDecoration(String label, TextTheme textTheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mainDarkColor),
      filled: true,
      fillColor: AppColors.altLightColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.mainDarkColor, width: 1.5),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                const SizedBox(height: 32),

                Text(
                  'Crie sua conta',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Campo Nome Completo
                TextFormField(
                  style: textTheme.bodyMedium,
                  decoration: _authInputDecoration('Nome Completo', textTheme),
                  validator: (value) => value == null || value.isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),

                // Campo E-mail
                TextFormField(
                  style: textTheme.bodyMedium,
                  decoration: _authInputDecoration('E-mail', textTheme),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),

                // Campo Senha
                TextFormField(
                  style: textTheme.bodyMedium,
                  obscureText: _obscurePassword,
                  decoration: _authInputDecoration('Senha', textTheme).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),

                // Botão de Cadastro
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Navega para a próxima etapa (2FA)
                        context.push('/2fa');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDarkColor,
                      foregroundColor: AppColors.mainWhiteColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),

                // Divisor Social
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OU')),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Botões Sociais (Critério de aceite)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: Text('Cadastrar com Google', style: textTheme.bodyMedium),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.facebook, size: 24),
                  label: Text('Cadastrar com Facebook', style: textTheme.bodyMedium),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}