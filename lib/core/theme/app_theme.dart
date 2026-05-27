import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1565C0);
  static const _errorColor = Color(0xFFD32F2F);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          error: _errorColor,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
          error: _errorColor,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  // Cores semânticas de prioridade
  static Color prioridadeColor(int index, {bool dark = false}) {
    const colors = [
      Color(0xFF4CAF50), // baixa - verde
      Color(0xFFFFA726), // média - laranja
      Color(0xFFEF5350), // alta - vermelho claro
      Color(0xFFB71C1C), // crítica - vermelho escuro
    ];
    return colors[index.clamp(0, 3)];
  }

  static Color statusColor(int index) {
    const colors = [
      Color(0xFF1976D2), // aberto - azul
      Color(0xFFF57C00), // em andamento - laranja
      Color(0xFF388E3C), // concluído - verde
    ];
    return colors[index.clamp(0, 2)];
  }
}
