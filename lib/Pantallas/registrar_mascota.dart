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
  final TextEditingController observacionesController = TextEditingController();

  File? _imagenSeleccionada;

  // NUEVOS CAMPOS
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
    final obs = observacionesController.text.trim();

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
        'observaciones': obs,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF2A74D9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar Mascota',
          style: TextStyle(
            color: azul,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
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
                            color: azul,
                          )
                          : null,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCardTextField(nombreController, 'Nombre'),
                ),
                const SizedBox(width: 10),

                // *** Sexo vertical ***
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sexo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Column(
                        children: [
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
                              const Text(
                                "Macho",
                                style: TextStyle(fontSize: 11),
                              ),
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
                              const Text(
                                "Hembra",
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // *** Esterilizado vertical ***
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Esterilizado",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Column(
                        children: [
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
                                onChanged:
                                    (v) => setState(() => esterilizado = v),
                              ),
                              const Text("Sí", style: TextStyle(fontSize: 11)),
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
                                onChanged:
                                    (v) => setState(() => esterilizado = v),
                              ),
                              const Text("No", style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

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

            Row(
              children: [
                Expanded(child: _buildCardTextField(colorController, 'Color')),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: azul.withOpacity(0.4),
                        width: 3.5,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Especie",
                        border: InputBorder.none,
                      ),
                      value: especie,
                      items:
                          especies
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => especie = v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _buildCardTextField(
              observacionesController,
              'Observaciones',
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarMascota,
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
                  backgroundColor: azul,
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
          color: const Color(0xFF2A74D9).withOpacity(0.4),
          width: 3.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
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
