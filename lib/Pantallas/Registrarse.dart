import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/Login.dart';
import 'package:flutter/services.dart';

class Registro extends StatefulWidget {
  static const routeName = '/registro';
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscure = true;

  // Errores
  String? _phoneError;
  String? _emailError;
  String? _passError;
  String? _confirmPassError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _outlineBlue(double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: const Color(0xFF4E78FF), width: w),
  );

  OutlineInputBorder _outlineRed(double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.red, width: w),
  );

  // ---------- Validadores ----------

  String? _validateTelefono(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Este campo es requerido';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Solo se permiten números';
    return null;
  }

  String? _validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Este campo es requerido';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
      return 'Formato de correo inválido';
    }
    return null;
  }

  String? _validatePass(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Este campo es requerido';
    if (v.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres';
    }
    return null;
  }

  String? _validateConfirmPass(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Este campo es requerido';
    if (v != _passCtrl.text.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // ---------- SnackBars con estilo ----------
  void _showStyledSnackBar(String message, {bool success = true}) {
    final Color bg =
        success ? const Color(0xFF4CAF50) : const Color(0xFFE53935);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Guarda el cliente en Firestore
  Future<void> _registrarCliente() async {
    final nombre = _nameCtrl.text.trim();
    final telefono = _phoneCtrl.text.trim();
    final correo = _emailCtrl.text.trim();
    final direccion = _addressCtrl.text.trim();
    final password = _passCtrl.text.trim();

    try {
      await FirebaseFirestore.instance.collection('clientes').add({
        'nombre': nombre,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'password': password, // Solo para prueba escolar
        'mascotas': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showStyledSnackBar('Registro exitoso', success: true);

      Navigator.pushReplacementNamed(context, Login.routeName);
    } catch (e) {
      if (!mounted) return;
      _showStyledSnackBar(
        'Error al registrar. Inténtalo de nuevo.',
        success: false,
      );
    }
  }

  // Validaciones + Confirmación
  Future<void> _confirmarRegistro() async {
    setState(() {
      _phoneError = _validateTelefono(_phoneCtrl.text);
      _emailError = _validateEmail(_emailCtrl.text);
      _passError = _validatePass(_passCtrl.text);
      _confirmPassError = _validateConfirmPass(_confirmPassCtrl.text);
    });

    if (_phoneError != null ||
        _emailError != null ||
        _passError != null ||
        _confirmPassError != null) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 8,
          ),
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
          ),
          title: Row(
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFD8E1FF),
                child: Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF0B1446),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Confirmar registro",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            "¿Deseas guardar tus datos y registrarte?",
            style: TextStyle(fontSize: 15),
          ),
          actionsPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 14,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1446),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                "Sí, registrarme",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _registrarCliente();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Flecha atrás sobre el degradado azul
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ), // 👈 más ancho
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 22),

                      _LabeledField(
                        label: 'Nombre',
                        controller: _nameCtrl,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),

                      _LabeledField(
                        label: 'Teléfono',
                        controller: _phoneCtrl,
                        icon: Icons.phone_iphone,
                        keyboardType: TextInputType.phone,
                        errorText: _phoneError,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _phoneError =
                                _validateTelefono(value) == null &&
                                        value.trim().isNotEmpty
                                    ? null
                                    : _validateTelefono(value);
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      _LabeledField(
                        label: 'Correo electrónico',
                        controller: _emailCtrl,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (value) {
                          setState(() {
                            _emailError =
                                _validateEmail(value) == null &&
                                        value.trim().isNotEmpty
                                    ? null
                                    : _validateEmail(value);
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      _LabeledField(
                        label: 'Dirección',
                        controller: _addressCtrl,
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),

                      // Contraseña
                      const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        onChanged: (value) {
                          setState(() {
                            _passError =
                                _validatePass(value) == null &&
                                        value.trim().isNotEmpty
                                    ? null
                                    : _validatePass(value);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Contraseña',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[500],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[500],
                            ),
                            onPressed:
                                () => setState(() => _obscure = !_obscure),
                          ),
                          errorText: _passError,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 204, 204, 204),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: _outlineBlue(1.4),
                          errorBorder: _outlineRed(1.2),
                          focusedErrorBorder: _outlineRed(1.4),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirmar contraseña
                      const Text(
                        'Confirmar contraseña',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscure,
                        onChanged: (value) {
                          setState(() {
                            _confirmPassError =
                                _validateConfirmPass(value) == null &&
                                        value.trim().isNotEmpty
                                    ? null
                                    : _validateConfirmPass(value);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Confirmar contraseña',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[500],
                          ),
                          errorText: _confirmPassError,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 204, 204, 204),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: _outlineBlue(1.4),
                          errorBorder: _outlineRed(1.2),
                          focusedErrorBorder: _outlineRed(1.4),
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF081B4D),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _confirmarRegistro,
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes una cuenta? '),
                          GestureDetector(
                            onTap:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  Login.routeName,
                                ),
                            child: const Text(
                              'Inicia Sesión aquí',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1446),
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
          ),
        ),
      ),
    );
  }
}

// ---------- Campo reutilizable con estilo del mockup ----------
class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.errorText,
    this.inputFormatters,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            prefixIcon:
                icon != null ? Icon(icon, color: Colors.grey[500]) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 204, 204, 204),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Color(0xFF4E78FF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
