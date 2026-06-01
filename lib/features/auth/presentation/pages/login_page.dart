import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importação oficial
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_remote_datasource.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Função oficial de Autenticação com Google
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. Inicializa a instância (S-I-G-N, com 'gn')
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // 2. Limpa qualquer sessão anterior para garantir a escolha da conta
      await googleSignIn.signOut(); 
      
      // 3. Abre o seletor de contas nativo do Android
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // Se o usuário selecionou uma conta, ativamos o notifier
        // Isso fará o AppRouter redirecionar automaticamente para a Home
        AppRouter.authNotifier.value = true;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bem-vindo, ${googleUser.displayName}!'),
              backgroundColor: AppColors.accentColor,
            ),
          );
        }
      }
    } catch (error) {
      // Caso ocorra algum erro na comunicação com o Google Cloud
      debugPrint('Erro Google Auth: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível conectar com o Google.'),
            backgroundColor: AppColors.detailsColor,
          ),
        );
      }
    }
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRemoteDataSource = AuthRemoteDataSource();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRemoteDataSource.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de verificação enviado por e-mail.'),
        ),
      );

      context.push('/2fa', extra: _emailController.text.trim());
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/logo.png', height: 48),
                const SizedBox(height: 48),
                Text(
                  'Acesse sua conta',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: AppColors.altLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!email.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: AppColors.altLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/esqueci-senha');
                    },
                    child: Text(
                      'Esqueci minha senha',
                      style: textTheme.bodySmall,
                    ),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                            'Entrar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OU'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Continuar com Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.facebook, size: 28),
                  label: const Text('Continuar com Facebook'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?'),
                    TextButton(
                      onPressed: () {
                        context.push('/cadastro');
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}