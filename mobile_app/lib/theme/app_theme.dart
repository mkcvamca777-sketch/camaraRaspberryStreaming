import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Oficial extraída del diseño de interfaz (Valentina Micaela Céspedes Álvarez | 2026)
  static const Color background = Color(0xFF080E1A);       // Fondo oscuro casi negro
  static const Color surface = Color(0xFF0F1A2E);          // Superficie / Paneles
  static const Color surfaceLight = Color(0xFF16253F);     // Inputs y controles elevados
  static const Color cardBorder = Color(0xFF1B2B48);       // Bordes sutiles de tarjetas
  
  static const Color primaryElectric = Color(0xFF0084FF);  // Azul eléctrico para controles principales
  static const Color primaryElectricGlow = Color(0xFF00A2FF);
  
  static const Color positiveGreen = Color(0xFF00C853);    // Verde para conexión activa y Push-to-Talk
  static const Color positiveGreenGlow = Color(0xFF00E676);
  
  static const Color dangerRed = Color(0xFFD50000);        // Rojo exclusivamente para alertas y STOP
  static const Color dangerRedGlow = Color(0xFFFF1744);
  
  static const Color warningAmber = Color(0xFFFFB300);     // Amarillo / Ámbar para 'En espera'
  
  static const Color textPrimary = Color(0xFFFFFFFF);      // Blanco
  static const Color textSecondary = Color(0xFF90A3BF);    // Gris claro / subtítulos
  static const Color textMuted = Color(0xFF566B88);        // Gris tenue

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryElectric,
      colorScheme: const ColorScheme.dark(
        primary: primaryElectric,
        secondary: primaryElectricGlow,
        surface: surface,
        background: background,
        error: dangerRed,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: primaryElectric),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryElectric,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Estilo Pill
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryElectric, width: 1.8),
        ),
      ),
    );
  }
}
