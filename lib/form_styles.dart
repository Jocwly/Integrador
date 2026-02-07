import 'package:flutter/material.dart';

class FormStyles {
  // ===== COLORES =====
  static const Color azulSuave = Color(0xFFF4F6FF);
  static const Color azulFuerte = Color(0xFF5F79FF);
  static const Color azulOscuro = Color(0xFF0B1446);
  static const Color fondoGradientTop = Color(0xFFD7D2FF);
  static const Color fondoGradientBottom = Color(0xFFF1EEFF);

  // ===== GRADIENTES =====
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [fondoGradientTop, fondoGradientBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===== BORDES INPUT =====
  static OutlineInputBorder softBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: azulFuerte.withOpacity(0.5), width: 1.3),
    );
  }

  static OutlineInputBorder grayBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: azulFuerte.withOpacity(0.25), width: 1.3),
    );
  }

  static OutlineInputBorder errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.red, width: 1.6),
    );
  }

  // ===== DECORACIÓN INPUT =====
  static InputDecoration inputDecoration({
    String? hint,
    IconData? icon,
    bool gray = false,
    bool error = false,
    String? suffixText,
  }) {
    final border = error ? errorBorder() : (gray ? grayBorder() : softBorder());

    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: azulOscuro, size: 20) : null,

      hintText: hint,
      filled: true,
      fillColor: azulSuave,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border,
      focusedBorder: border,
      border: InputBorder.none,
      suffixText: suffixText,
    );
  }

  // ===== TEXTO LABEL DE CAMPOS =====
  static const TextStyle labelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Colors.black87,
  );

  // ===== TEXTO ERROR =====
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ===== TITULO NOMBRE MASCOTA =====
  static const TextStyle mascotaNombre = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 22,
    color: azulOscuro,
  );

  // ===== CHIP "PACIENTE" =====
  static BoxDecoration pacienteChipDecoration = BoxDecoration(
    color: azulOscuro.withOpacity(.08),
    borderRadius: BorderRadius.circular(20),
  );

  static const TextStyle pacienteChipText = TextStyle(
    fontSize: 11,
    color: azulFuerte,
    fontWeight: FontWeight.w600,
  );

  // ===== TARJETA CONTENEDORA =====
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: const [
      BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );

  // ===== BOTÓN PRINCIPAL =====
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: azulOscuro,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );

  // ===== BOTÓN OUTLINE =====
  static ButtonStyle outlineButton = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );

  static const Divider formDivider = Divider(
    thickness: 1.5,
    height: 25,
    color: Color.fromARGB(255, 182, 181, 181),
  );

  // ===== ESPACIADOS =====
  static const SizedBox spaceSmall = SizedBox(height: 6);
  static const SizedBox spaceMedium = SizedBox(height: 16);
  static const SizedBox spaceLarge = SizedBox(height: 24);
}
