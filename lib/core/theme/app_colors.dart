import 'package:flutter/material.dart';

class AppColors {
  // Cores Principais
  static const Color mainDarkColor = Color(0xFF0C1B33);
  static const Color mainWhiteColor = Color(0xFFFFFFFF);

  // Cores de Destaque (Accents)
  static const Color accentColor = Color(0xFF07FFA8); // Verde Neon
  static const Color accentColor2 = Color(0xFFDE9E36); // Dourado/Amarelo

  // Cores Alternativas e Detalhes
  static const Color altDarkColor = Color(0xFF404E4D); // Cinza Escuro/Grafite
  static const Color altLightColor = Color(0xFFE7EEFA); // Azulzinho muito claro
  static const Color detailsColor = Color(0xFFC3423F); // Vermelho/Coral

  // Semânticas
  static const Color background = mainDarkColor;
  static const Color surface = altDarkColor;
  static const Color error = detailsColor;

  // Cores Específicas para Card Precedente
  static const Color primaryColor = mainDarkColor; // Para o Divider
  static const Color backgroundBlueCard = altLightColor; // Para o fundo lateral
  static const Color successColor = accentColor; // Para "Muito Provável"
  static const Color warningColor = Color(0xFFC3423F); // Para "Pouco Provável"
}
