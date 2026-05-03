import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessando o tema centralizado
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      // Usa a cor principal do seu ColorScheme (AppColors.mainDarkColor)
      backgroundColor: colorScheme.primary,
      child: Column(
        children: [
          // Cabeçalho do Menu
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Center(
              child: RichText(
                text: TextSpan(
                  // Usando o estilo de título do seu tema como base
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(text: 'Precedent'),
                    TextSpan(
                      text: 'IA',
                      // Usa a cor secundária (AppColors.accentColor)
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Itens de Navegação
          _buildMenuItem(context, Icons.home_outlined, "Home", "/search"),
          _buildMenuItem(
            context,
            Icons.description_outlined,
            "Precedentes",
            "/precedents",
          ),
          _buildMenuItem(context, Icons.person_outline, "Perfil", "/profile"),

          const Spacer(),

          // Item de Sair - Usando a cor de erro (AppColors.detailsColor)
          _buildMenuItem(
            context,
            Icons.logout,
            "Sair",
            "/login",
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Define a cor baseada se o item é "destrutivo" (Sair) ou comum
    final Color itemColor = isDestructive
        ? colorScheme.error
        : colorScheme.secondary;
    final Color textColor = isDestructive ? colorScheme.error : Colors.white;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: textTheme.titleSmall?.copyWith(color: textColor),
      ),
      onTap: () {
        context.pop(); // Fecha o drawer (GoRouter way)
        context.go(route); // Navega para a rota usando GoRouter
      },
    );
  }
}
