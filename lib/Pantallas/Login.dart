import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/veterinario/veterinario.dart';
import 'package:login/Pantallas/Registrarse.dart';
import 'package:login/Pantallas/Dueno/Mascotadueno.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _isLoading = false;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final passPlano = _passCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      // PROTECCIÓN SQLi
      final query =
          await FirebaseFirestore.instance
              .collection('clientes')
              .where('correo', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        throw 'Usuario no encontrado';
      }

      final userDoc = query.docs.first;
      final data = userDoc.data();

      //VALIDACIÓN BACKEND (password)
      final stored = data['password'];
      final parts = stored.split(':');

      if (parts.length != 2) throw 'Error de seguridad';

      final hash = parts[0];
      final salt = parts[1];

      final newHash = sha256.convert(utf8.encode(passPlano + salt)).toString();

      if (newHash != hash) {
        throw 'Contraseña incorrecta';
      }

      // logs (login exitoso)
      await FirebaseFirestore.instance.collection('logs').add({
        'evento': 'login',
        'correo': email,
        'fecha': FieldValue.serverTimestamp(),
        'exito': true,
      });

      //Roles
      final rol = data['rol'];

      if (!mounted) return;

      if (rol == 'veterinario') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => Veterinario(
                  veterinarioId: userDoc.id, // 🔥 AQUÍ VA EL ID
                ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Mascotadueno(clienteId: userDoc.id),
          ),
        );
      }
    } catch (e) {
      // Logs (login fallido)
      await FirebaseFirestore.instance.collection('logs').add({
        'evento': 'login',
        'correo': email,
        'fecha': FieldValue.serverTimestamp(),
        'exito': false,
        'error': e.toString(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF081B4D);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                // Tarjeta blanca centrada y redondeada
                child: Card(
                  elevation: 10,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: const AssetImage(
                              'assets/images/petcare_logo.jpg',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PetCare',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Gestión médica para mascotas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7C8EB5),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _FilledField(
                            controller: _emailCtrl,
                            label: 'Correo Electrónico',
                            hint: 'tu@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Completa este campo';
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(text)) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _FilledField(
                            controller: _passCtrl,
                            label: 'Contraseña',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscure = !_obscure);
                              },
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Completa este campo';
                              }
                              if (text.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              return null;
                            },
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
                                  borderRadius: BorderRadius.circular(19),
                                ),
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        _handleLogin();
                                      },
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'Iniciar Sesión',
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
                              const Text('¿No tienes una cuenta?  '),
                              GestureDetector(
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      Registro.routeName,
                                    ),
                                child: const Text(
                                  'Regístrate aquí',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                    color: darkBlue,
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
        ),
      ),
    );
  }
}

class _FilledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _FilledField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E5F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5F79FF), width: 1.6),
        ),
      ),
    );
  }
}
