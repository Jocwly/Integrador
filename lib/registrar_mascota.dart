import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistrarMascota extends StatefulWidget {
  const RegistrarMascota({super.key});

  @override
  State<RegistrarMascota> createState() => _RegistrarMascotaState();
}

class _RegistrarMascotaState extends State<RegistrarMascota> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController razaController = TextEditingController();
  final TextEditingController tamanoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  File? _imagenSeleccionada;

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2A74D9),
          ),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'Registrar Mascota',
          style: TextStyle(
            color: Color(0xFF2A74D9),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Imagen del perfil de mascota
            GestureDetector(
              onTap: _seleccionarImagen,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFFDDE6F8),
                backgroundImage:
                    _imagenSeleccionada != null
                        ? FileImage(_imagenSeleccionada!)
                        : null,
                child:
                    _imagenSeleccionada == null
                        ? const Icon(
                          Icons.add_a_photo_rounded,
                          size: 32,
                          color: Color(0xFF2A74D9),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 25),

            // Campos
            _buildCardTextField(nombreController, 'Nombre'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCardTextField(edadController, 'Edad')),
                const SizedBox(width: 12),
                Expanded(child: _buildCardTextField(razaController, 'Raza')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCardTextField(tamanoController, 'Tamaño'),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildCardTextField(pesoController, 'Peso')),
              ],
            ),
            const SizedBox(height: 12),
            _buildCardTextField(colorController, 'Color'),
            const SizedBox(height: 12),
            _buildCardTextField(
              observacionesController,
              'Observaciones',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos guardados correctamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text(
                  'GUARDAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A74D9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Campo con estilo de tarjeta (sin borde, con sombra y fondo blanco)
  Widget _buildCardTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2A74D9).withOpacity(0.4), // Azul con opacidad
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
