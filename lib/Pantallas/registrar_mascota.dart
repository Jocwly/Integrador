import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

  bool _mostrarErrores = false;

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

  final List<String> razasCaninos = [
    "Labrador Retriever",
    "Pastor Alemán",
    "Bulldog",
    "Poodle",
    "Chihuahua",
    "Golden Retriever",
    "Beagle",
    "Rottweiler",
    "Doberman",
    "Pug",
    "Husky Siberiano",
    "Pitbull",
  ];

  final List<String> razasFelinos = [
    "Siamés",
    "Persa",
    "Maine Coon",
    "Bengalí",
    "Angora",
    "Sphynx",
    "British Shorthair",
    "Ragdoll",
    "Bombay",
    "Azul Ruso",
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

    if (nombre.isEmpty ||
        especie == null ||
        sexo == null ||
        esterilizado == null ||
        edad.isEmpty ||
        raza.isEmpty ||
        tamano.isEmpty ||
        peso.isEmpty ||
        color.isEmpty) {
      setState(() {
        _mostrarErrores = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar mascota',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO + "Nueva mascota"
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 20, 66),
                  width: 3,
                ),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imagenSeleccionada != null
                          ? FileImage(_imagenSeleccionada!)
                          : null,
                  child:
                      _imagenSeleccionada == null
                          ? const Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 28,
                          )
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 13, 0, 60),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Text(
                'Nueva mascota',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: azulSuave,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(
                    'Nombre de la mascota:',
                    isError:
                        _mostrarErrores && nombreController.text.trim().isEmpty,
                  ),
                  _buildTextFieldBox(
                    controller: nombreController,
                    isError:
                        _mostrarErrores && nombreController.text.trim().isEmpty,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(
                    'Especie:',
                    isError: _mostrarErrores && especie == null,
                  ),
                  _buildDropdownBox<String>(
                    value: especie,
                    hint: 'Seleccionar',
                    items: especies,
                    isError: _mostrarErrores && especie == null,
                    onChanged: (value) {
                      setState(() {
                        especie = value;
                        razaController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Sexo:',
                              isError: _mostrarErrores && sexo == null,
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "Macho",
                                  groupValue: sexo,
                                  activeColor: const Color.fromARGB(
                                    255,
                                    13,
                                    0,
                                    60,
                                  ),
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged: (v) => setState(() => sexo = v),
                                ),
                                const Text(
                                  "Macho",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "Hembra",
                                  groupValue: sexo,
                                  activeColor: const Color.fromARGB(
                                    255,
                                    13,
                                    0,
                                    60,
                                  ),
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged: (v) => setState(() => sexo = v),
                                ),
                                const Text(
                                  "Hembra",
                                  style: TextStyle(fontSize: 13),
                                ),
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
                            _buildLabel(
                              'Esterilizado:',
                              isError: _mostrarErrores && esterilizado == null,
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "Sí",
                                  groupValue: esterilizado,
                                  activeColor: const Color.fromARGB(
                                    255,
                                    13,
                                    0,
                                    60,
                                  ),
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged:
                                      (v) => setState(() => esterilizado = v),
                                ),
                                const Text(
                                  "Sí",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "No",
                                  groupValue: esterilizado,
                                  activeColor: const Color.fromARGB(
                                    255,
                                    13,
                                    0,
                                    60,
                                  ),
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged:
                                      (v) => setState(() => esterilizado = v),
                                ),
                                const Text(
                                  "No",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Edad:',
                              isError:
                                  _mostrarErrores &&
                                  edadController.text.trim().isEmpty,
                            ),
                            _buildTextFieldBox(
                              controller: edadController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,2}(\.\d{0,2})?$'),
                                ),
                              ],
                              suffixText: 'años',
                              isError:
                                  _mostrarErrores &&
                                  edadController.text.trim().isEmpty,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Raza:',
                              isError:
                                  _mostrarErrores &&
                                  razaController.text.trim().isEmpty,
                            ),
                            _buildRazaField(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Tamaño:',
                              isError:
                                  _mostrarErrores &&
                                  tamanoController.text.trim().isEmpty,
                            ),
                            _buildTextFieldBox(
                              controller: tamanoController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'[0-9]'),
                                ),
                              ],
                              isError:
                                  _mostrarErrores &&
                                  tamanoController.text.trim().isEmpty,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Peso:',
                              isError:
                                  _mostrarErrores &&
                                  pesoController.text.trim().isEmpty,
                            ),
                            _buildTextFieldBox(
                              controller: pesoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                                ),
                              ],
                              suffixText: 'kg',
                              isError:
                                  _mostrarErrores &&
                                  pesoController.text.trim().isEmpty,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildLabel(
                    'Color:',
                    isError:
                        _mostrarErrores && colorController.text.trim().isEmpty,
                  ),
                  _buildTextFieldBox(
                    controller: colorController,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                    ],
                    isError:
                        _mostrarErrores && colorController.text.trim().isEmpty,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardarMascota,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              13,
                              0,
                              60,
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTextFieldBox({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    bool isError = false,
  }) {
    final borderColor =
        isError ? Colors.red : const Color(0xFF2A74D9).withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixText: suffixText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownBox<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hint,
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
        hint: hint != null ? Text(hint) : null,
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black87),
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

  Widget _buildRazaField() {
    final bool isError = _mostrarErrores && razaController.text.trim().isEmpty;

    if (especie == "Canino" || especie == "Felino") {
      final opciones = especie == "Canino" ? razasCaninos : razasFelinos;

      return _buildDropdownBox<String>(
        value: razaController.text.isEmpty ? null : razaController.text,
        items: opciones,
        hint: 'Seleccionar',
        isError: isError,
        onChanged: (value) {
          setState(() {
            razaController.text = value ?? '';
          });
        },
      );
    }

    return _buildTextFieldBox(controller: razaController, isError: isError);
  }
}
