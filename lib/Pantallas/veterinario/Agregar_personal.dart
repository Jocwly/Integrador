import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AgregarPersonal extends StatefulWidget {
  const AgregarPersonal({super.key});

  @override
  State<AgregarPersonal> createState() => _AgregarPersonalState();
}

class _AgregarPersonalState extends State<AgregarPersonal> {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();

  String rolSeleccionado = 'Asistente';
  bool cargando = false;
  bool _mostrarErrores = false;

  Future<void> _guardarPersonal() async {
    final nombre = nombreCtrl.text.trim();
    final correo = correoCtrl.text.trim();
    final telefono = telefonoCtrl.text.trim();

    if (nombre.isEmpty || correo.isEmpty) {
      setState(() => _mostrarErrores = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor llena los campos obligatorios'),
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      await FirebaseFirestore.instance.collection('personal').add({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'rol': rolSeleccionado,
        'fechaRegistro': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal agregado correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => cargando = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al guardar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF2A74D9);
    const fondo = Color(0xFFF5F7FB);
    const azulSuave = Color(0xFFD6E1F7);

    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text(
          'Agregar personal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: azulSuave,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 NOMBRE
                          _buildLabel(
                            'Nombre:',
                            isError:
                                _mostrarErrores &&
                                nombreCtrl.text.trim().isEmpty,
                          ),
                          _buildTextFieldBox(
                            controller: nombreCtrl,
                            icon: Icons.person,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-ZÁÉÍÓÚáéíóúÑñ\s]'),
                              ),
                            ],
                            isError:
                                _mostrarErrores &&
                                nombreCtrl.text.trim().isEmpty,
                          ),

                          const SizedBox(height: 16),

                          // 🔹 CORREO
                          _buildLabel(
                            'Correo:',
                            isError:
                                _mostrarErrores &&
                                correoCtrl.text.trim().isEmpty,
                          ),
                          _buildTextFieldBox(
                            controller: correoCtrl,
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            isError:
                                _mostrarErrores &&
                                correoCtrl.text.trim().isEmpty,
                          ),

                          const SizedBox(height: 16),

                          // 🔹 TELÉFONO
                          _buildLabel('Teléfono:'),
                          _buildTextFieldBox(
                            controller: telefonoCtrl,
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          // 🔹 ROL
                          _buildLabel('Rol:'),
                          _buildDropdownBox<String>(
                            value: rolSeleccionado,
                            items: ['Veterinario', 'Asistente'],
                            onChanged: (value) {
                              setState(() {
                                rolSeleccionado = value!;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // 🔹 BOTÓN
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _guardarPersonal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azul,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

          if (cargando)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // 🔹 LABEL
  Widget _buildLabel(String text, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isError ? Colors.red : Colors.black87,
        ),
      ),
    );
  }

  // 🔹 TEXTFIELD ESTILO
  Widget _buildTextFieldBox({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isError = false,
    IconData? icon,
  }) {
    final borderColor =
        isError ? Colors.red : const Color(0xFF2A74D9).withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon:
              icon != null
                  ? Icon(icon, size: 20, color: Colors.grey[700])
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  // 🔹 DROPDOWN ESTILO
  Widget _buildDropdownBox<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool isError = false,
  }) {
    final borderColor =
        isError ? Colors.red : const Color(0xFF2A74D9).withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: const InputDecoration(border: InputBorder.none),
        items:
            items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
