import 'package:flutter/material.dart';
import 'package:login/Login.dart';
import 'package:login/veterinario.dart';

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
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _outlineBlue(double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF5F79FF), width: w),
      );

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
              // Logo
              const CircleAvatar(
                radius: 44,
                backgroundImage: AssetImage('assets/images/petcare_logo.png'), // reemplaza por tu logo
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              const Text('Registrarse', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),

              _LabeledField(label: 'Nombre:', icon: Icons.person_outline, controller: _nameCtrl),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Teléfono:',
                icon: Icons.phone_outlined,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Correo electrónico:',
                icon: Icons.mail_outline,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _LabeledField(label: 'Dirección:', icon: Icons.home_outlined, controller: _addressCtrl),
              const SizedBox(height: 12),

              // Contraseña con mostrar/ocultar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contraseña:', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, Veterinario.routeName),
                  child: const Text('Registrarse', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta? '),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, Login.routeName),
                    child: const Text('Inicia sesión aquí', style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(height: 4, width: 140, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
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
  const _LabeledField({required this.label, required this.icon, required this.controller, this.keyboardType});

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
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: _outlineBlue(1.2),
            focusedBorder: _outlineBlue(1.6),
          ),
        ),
      ],
    );
  }
}
