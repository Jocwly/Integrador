import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarMascota extends StatefulWidget {
  final String clienteId;
  const RegistrarMascota({super.key, required this.clienteId});

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

  File? _imagenSeleccionada;

  String? especie;
  String? sexo;
  String? esterilizado;

  final List<String> especies = [
    "Canino",
    "Felino",
    "Bovino",
    "Equino",
    "Porcino",
    "Ovino",
    "Caprino",
    "Aves",
    "Reptil",
    "Roedor",
    "Mustélido",
    "Pez",
  ];

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<void> _guardarMascota() async {
    final nombre = nombreController.text.trim();
    final edad = edadController.text.trim();
    final raza = razaController.text.trim();
    final tamano = tamanoController.text.trim();
    final peso = pesoController.text.trim();
    final color = colorController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe al menos el nombre')),
      );
      return;
    }

    try {
      final clienteRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId);

      await clienteRef.collection('mascotas').add({
        'nombre': nombre,
        'edad': edad,
        'raza': raza,
        'tamano': tamano,
        'peso': peso,
        'color': color,
        'especie': especie,
        'sexo': sexo,
        'esterilizado': esterilizado,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await clienteRef.update({'mascotas': FieldValue.increment(1)});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota registrada correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF2A74D9);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar Mascota',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO (círculo gris con icono negro)
            Center(
              child: GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: _imagenSeleccionada != null
                      ? FileImage(_imagenSeleccionada!)
                      : null,
                  child: _imagenSeleccionada == null
                      ? const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 34,
                          color: Colors.black87,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // NOMBRE
            _buildOutlinedTextField(nombreController, 'Nombre'),
            const SizedBox(height: 12),

            // ESPECIE
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Especie',
                labelStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: azul.withOpacity(0.7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: azul.withOpacity(0.7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: azul, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              value: especie,
              items: especies
                  .map(
                    (e) =>
                        DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => especie = v),
            ),

            const SizedBox(height: 16),

            // SEXO / ESTERILIZADO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sexo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "Macho",
                            groupValue: sexo,
                            activeColor: azul,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onChanged: (v) => setState(() => sexo = v),
                          ),
                          const Text("Macho", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "Hembra",
                            groupValue: sexo,
                            activeColor: azul,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onChanged: (v) => setState(() => sexo = v),
                          ),
                          const Text("Hembra", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Esterilizado",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "Sí",
                            groupValue: esterilizado,
                            activeColor: azul,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onChanged: (v) =>
                                setState(() => esterilizado = v),
                          ),
                          const Text("Sí", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "No",
                            groupValue: esterilizado,
                            activeColor: azul,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onChanged: (v) =>
                                setState(() => esterilizado = v),
                          ),
                          const Text("No", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // EDAD / RAZA
            Row(
              children: [
                Expanded(
                  child: _buildOutlinedTextField(edadController, 'Edad'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOutlinedTextField(razaController, 'Raza'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TAMAÑO / PESO
            Row(
              children: [
                Expanded(
                  child: _buildOutlinedTextField(tamanoController, 'Tamaño'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOutlinedTextField(pesoController, 'Peso'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // COLOR
            _buildOutlinedTextField(colorController, 'Color'),
            const SizedBox(height: 12),

            const SizedBox(height: 24),

            // BOTONES GUARDAR / CANCELAR
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardarMascota,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2A5F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3D3D3),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- TextField con borde azul fino (como el mockup) ----
  Widget _buildOutlinedTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    const azul = Color(0xFF2A74D9);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: azul.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: azul.withOpacity(0.7)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: azul, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
