import 'package:flutter/material.dart';

class FormStyles {
  // ===== COLORES =====

  static const Color azulSuave = /*Color(0xFFF4F6FF); Color(0xFFE7F0FF);*/
      Color(0xFFD6E6FF);

  static const Color azulFuerte = Color(0xFF2A74D9);
  static const Color azulOscuro = Color(0xFF0B1446);
  static const Color azulPrincipal = Color(0xFF4E78FF);
  static const Color fondo = Color(0xFFF5F7FB);
  //static const Color azulBoton = Color(0xFF2A74D9);
  static const Color fondoGradientTop = Color.fromARGB(255, 229, 231, 233);
  static const Color fondoGradientBottom = Color.fromARGB(255, 229, 231, 233);

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
      fillColor: azulSuave.withOpacity(0.30),
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
  // ===== AVATAR MASCOTA =====
  static BoxDecoration avatarBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: azulFuerte, width: 3),
  );

  static const double avatarPadding = 4;
  static const double avatarRadius = 46;

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
    backgroundColor: azulFuerte,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );

  // ===== BOTÓN OUTLINE =====
  static ButtonStyle outlineButton = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    foregroundColor: const Color(0xFF2A74D9),
  );

  static const Divider formDivider = Divider(
    thickness: 1.5,
    height: 25,
    color: Color.fromARGB(255, 182, 181, 181),
  );

  static InputDecoration inputDecorationLabel(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF4F6FF),
      prefixIcon: Icon(icon, color: azulFuerte),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: azulFuerte.withOpacity(.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: azulFuerte.withOpacity(.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: azulFuerte, width: 1.5),
      ),
    );
  }

  static BoxDecoration personalCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE7F0FF), Color(0xFFD6E6FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(color: azulFuerte.withOpacity(0.25)),
  );
  static BoxDecoration chipDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: azulFuerte.withOpacity(0.2)),
  );

  static const TextStyle chipLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle chipValue = TextStyle(fontSize: 14);

  // 🔷 DROPDOWN
  static InputDecoration dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF4F6FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: azulPrincipal.withOpacity(.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: azulPrincipal.withOpacity(.2)),
      ),
    );
  }

  // 🔷 BOTÓN PRINCIPAL
  static ButtonStyle botonPrincipal() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: azulPrincipal,
      elevation: 4,
    );
  }

  // 🔷 DIALOG
  static BoxDecoration dialogDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
    );
  }

  static ShapeBorder dialogShape() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
  }

  // ===== ESPACIADOS =====
  static const SizedBox spaceSmall = SizedBox(height: 6);
  static const SizedBox spaceMedium = SizedBox(height: 16);
  static const SizedBox spaceLarge = SizedBox(height: 24);
}
