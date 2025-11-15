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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

      Navigator.pushReplacementNamed(context, Login.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
    }
  }

  // Validaciones + Confirmación
  Future<void> _confirmarRegistro() async {
    setState(() {
      _phoneError =
          RegExp(r'^[0-9]+$').hasMatch(_phoneCtrl.text.trim())
              ? null
              : 'Solo se permiten números';

      _emailError =
          RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(_emailCtrl.text.trim())
              ? null
              : 'Formato de correo inválido';

      _passError =
          _passCtrl.text.trim().length >= 6
              ? null
              : 'La contraseña debe tener mínimo 6 caracteres';

      _confirmPassError =
          _confirmPassCtrl.text.trim() == _passCtrl.text.trim()
              ? null
              : 'Las contraseñas no coinciden';
    });

    // Si hay errores, no continúa
    if (_phoneError != null ||
        _emailError != null ||
        _passError != null ||
        _confirmPassError != null) {
      return;
    }

    // Abrir diálogo
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmar registro"),
            content: const Text("¿Deseas guardar tus datos y registrarte?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1446),
                ),
                child: const Text("Sí, registrarme"),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await _registrarCliente();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundImage: AssetImage('assets/images/petcare_logo.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              const Text(
                'Registrarse',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),

              _LabeledField(
                label: 'Nombre:',
                icon: Icons.person_outline,
                controller: _nameCtrl,
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
              ),
              const SizedBox(height: 12),

              _LabeledField(
                label: 'Correo electrónico:',
                icon: Icons.mail_outline,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 12),

              _LabeledField(
                label: 'Dirección:',
                icon: Icons.home_outlined,
                controller: _addressCtrl,
              ),
              const SizedBox(height: 12),

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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      errorText: _passError,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: _outlineBlue(1.2),
                      focusedBorder: _outlineBlue(1.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: _confirmPassError,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: _outlineBlue(1.2),
                      focusedBorder: _outlineBlue(1.6),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmarRegistro,
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 10),
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

  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.errorText,
    this.inputFormatters,
  });

  OutlineInputBorder _outlineBlue(double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: const Color(0xFF5F79FF), width: w),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: _outlineBlue(1.2),
            focusedBorder: _outlineBlue(1.6),
          ),
        ),
      ],
    );
  }
}
