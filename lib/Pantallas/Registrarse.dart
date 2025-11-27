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
    borderSide: BorderSide(color: const Color(0xFF5F79FF), width: w),
  );

  OutlineInputBorder _outlineRed(double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.red, width: w),
  );

  // ---------- Validadores reutilizables ----------

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
        success
            ? const Color(0xFF4CAF50) // verde éxito
            : const Color(0xFFE53935); // rojo error

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

      _showStyledSnackBar('Registro exitoso ✅', success: true);

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
    // Validamos TODO al presionar el botón
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
    const pillBlue = Color(0xFFD8E1FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1446), Color(0xFF5F79FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: pillBlue,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Image(
                            image: AssetImage('assets/images/petcare_logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B1446),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _LabeledField(
                        label: 'Nombre:',
                        icon: Icons.person_2_rounded,
                        controller: _nameCtrl,
                        outlineBlue: _outlineBlue,
                        outlineRed: _outlineRed,
                      ),
                      const SizedBox(height: 12),

                      _LabeledField(
                        label: 'Teléfono:',
                        icon: Icons.phone_outlined,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        errorText: _phoneError,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        outlineBlue: _outlineBlue,
                        outlineRed: _outlineRed,
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
                      const SizedBox(height: 12),

                      _LabeledField(
                        label: 'Correo electrónico:',
                        icon: Icons.mail_rounded,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        outlineBlue: _outlineBlue,
                        outlineRed: _outlineRed,
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
                      const SizedBox(height: 12),

                      _LabeledField(
                        label: 'Dirección:',
                        icon: Icons.home_filled,
                        controller: _addressCtrl,
                        outlineBlue: _outlineBlue,
                        outlineRed: _outlineRed,
                      ),
                      const SizedBox(height: 12),

                      // Contraseña
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contraseña:',
                            style: TextStyle(fontWeight: FontWeight.w700),
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
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed:
                                    () => setState(() => _obscure = !_obscure),
                              ),
                              errorText: _passError,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: _outlineBlue(1.2),
                              focusedBorder: _outlineBlue(1.6),
                              errorBorder: _outlineRed(1.3),
                              focusedErrorBorder: _outlineRed(1.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Confirmar contraseña
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confirmar contraseña:',
                            style: TextStyle(fontWeight: FontWeight.w700),
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
                              prefixIcon: const Icon(Icons.lock_rounded),
                              errorText: _confirmPassError,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: _outlineBlue(1.2),
                              focusedBorder: _outlineBlue(1.6),
                              errorBorder: _outlineRed(1.3),
                              focusedErrorBorder: _outlineRed(1.6),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B1446),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _confirmarRegistro,
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
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
                              'Inicia sesión aquí',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1446),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      Container(
                        height: 4,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
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

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final OutlineInputBorder Function(double)? outlineBlue;
  final OutlineInputBorder Function(double)? outlineRed;
  final ValueChanged<String>? onChanged;

  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.errorText,
    this.inputFormatters,
    this.outlineBlue,
    this.outlineRed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ob =
        outlineBlue ??
        (double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xFF5F79FF), width: 20),
        );
    final or =
        outlineRed ??
        (double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red, width: 20),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: ob(1.2),
            focusedBorder: ob(1.6),
            errorBorder: or(1.3),
            focusedErrorBorder: or(1.6),
          ),
        ),
      ],
    );
  }
}
