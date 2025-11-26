import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:login/Pantallas/veterinario.dart';
import 'package:login/Pantallas/registro.dart';
import 'package:login/Pantallas/mascotadueno.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  bool _isLoading = false;

  // 🔐 Credenciales predeterminadas del veterinario
  static const String _vetEmail = 'veterinario@petcare.com';
  static const String _vetPass = 'vet123456';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa correo y contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Verificar si es el veterinario
      if (email == _vetEmail && pass == _vetPass) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Veterinario.routeName);
        return;
      }

      // 2️⃣ Si no es veterinario, buscar en la colección "clientes"
      final query = await FirebaseFirestore.instance
          .collection('clientes')
          .where('correo', isEqualTo: email)
          .where('password', isEqualTo: pass)
          .limit(1)
          .get();

      if (!mounted) return;

      if (query.docs.isNotEmpty) {
        // Cliente encontrado → va a MascotaDueño
        Navigator.pushReplacementNamed(context, Mascotadueno.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo o contraseña incorrectos')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillBlue = const Color(0xFFD8E1FF);
    final darkBlue = const Color(0xFF0B1446);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 85,
                backgroundColor: pillBlue,
                backgroundImage: const AssetImage(
                  'assets/images/petcare_logo.jpg',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PETCARE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 28),

              _FilledField(
                controller: _emailCtrl,
                hint: 'Correo electrónico',
                icon: Icons.email_rounded,
                background: pillBlue,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _FilledField(
                controller: _passCtrl,
                hint: 'Contraseña',
                icon: Icons.lock,
                background: pillBlue,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta? '),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, Registro.routeName),
                    child: const Text(
                      'Regístrate aquí',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color background;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _FilledField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.background,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        hintText: hint,
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: background, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5F79FF), width: 1.4),
        ),
      ),
    );
  }
}
