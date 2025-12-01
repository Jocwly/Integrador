import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrarMascota extends StatefulWidget {
  final String clienteId;
  final String? fotoUrlInicial;

  const RegistrarMascota({
    super.key,
    required this.clienteId,
    this.fotoUrlInicial,
  });

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
  String? _fotoUrlRemota;
  String? especie;
  String? sexo;
  String? esterilizado;
  String _unidadEdad = 'años';

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
    "Mestizo",
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
    "Mestizo",
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

  @override
  void initState() {
    super.initState();
    _fotoUrlRemota = widget.fotoUrlInicial;
  }

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

  // 👀 Ya NO validamos que haya foto
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
    final clienteRef =
        FirebaseFirestore.instance.collection('clientes').doc(widget.clienteId);

    final mascotaRef = clienteRef.collection('mascotas').doc();

    // 🔹 Foto puede ser null o venir de inicial
    String? fotoUrl = _fotoUrlRemota;

    // 🔹 Solo subimos a Storage si el usuario seleccionó una imagen nueva
    if (_imagenSeleccionada != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('mascotas')
            .child(widget.clienteId)
            .child('${mascotaRef.id}.jpg');

        final snapshot = await storageRef.putFile(
          _imagenSeleccionada!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        fotoUrl = await snapshot.ref.getDownloadURL();
      } on FirebaseException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: ${e.message}')),
        );
        return;
      }
    }

    await mascotaRef.set({
      'nombre': nombre,
      'edad': '$edad $_unidadEdad',
      'raza': raza,
      'tamano': tamano,
      'peso': peso,
      'color': color,
      'especie': especie,
      'sexo': sexo,
      'esterilizado': esterilizado,
      // 👇 Puede ser null si no se subió foto
      'fotoUrl': fotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await clienteRef.update({'mascotas': FieldValue.increment(1)});

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          title: Row(
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFD6E1F7),
                child: Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF0B1446),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Mascota agregada',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Se agregó la mascota "$nombre" correctamente.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1446),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);

    final ImageProvider? avatarImage = _imagenSeleccionada != null
        ? FileImage(_imagenSeleccionada!)
        : (_fotoUrlRemota != null && _fotoUrlRemota!.isNotEmpty
            ? NetworkImage(_fotoUrlRemota!) as ImageProvider
            : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // 🔹 menos padding lateral para ganar ancho
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: ConstrainedBox(
                // 🔹 más ancho máximo
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔹 Barra superior personalizada
                    Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.pets_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Registrar mascota',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Tarjeta principal más ancha
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          // un poquito menos de padding horizontal
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 22,
                          ),
                          child: Column(
                            children: [
                              // FOTO
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 0, 20, 66),
                                    width: 3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: _seleccionarImagen,
                                  child: CircleAvatar(
                                    radius: 52,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: avatarImage,
                                    child: avatarImage == null
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: const Text(
                                  'Nueva mascota',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // FORM
                              Container(
                                width: double.infinity, // 🔹 ocupa todo el ancho
                                decoration: BoxDecoration(
                                  color: azulSuave,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.all(14), // 🔹 menos padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nombre
                                    _buildLabel(
                                      'Nombre de la mascota:',
                                      isError: _mostrarErrores &&
                                          nombreController.text
                                              .trim()
                                              .isEmpty,
                                    ),
                                    _buildTextFieldBox(
                                      controller: nombreController,
                                      isError: _mostrarErrores &&
                                          nombreController.text
                                              .trim()
                                              .isEmpty,
                                      icon: Icons.pets_rounded,
                                    ),
                                    const SizedBox(height: 16),

                                    // Especie y raza
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Especie:',
                                                isError: _mostrarErrores &&
                                                    especie == null,
                                              ),
                                              _buildDropdownBox<String>(
                                                value: especie,
                                                hint: 'Seleccionar',
                                                items: especies,
                                                isError: _mostrarErrores &&
                                                    especie == null,
                                                onChanged: (value) {
                                                  setState(() {
                                                    especie = value;
                                                    razaController.clear();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10), // 🔹 menos espacio
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Raza:',
                                                isError: _mostrarErrores &&
                                                    razaController.text
                                                        .trim()
                                                        .isEmpty,
                                              ),
                                              _buildRazaField(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Edad y color
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Edad:',
                                                isError: _mostrarErrores &&
                                                    edadController.text
                                                        .trim()
                                                        .isEmpty,
                                              ),
                                              _buildEdadField(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10), // 🔹 menos espacio
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Color:',
                                                isError: _mostrarErrores &&
                                                    colorController.text
                                                        .trim()
                                                        .isEmpty,
                                              ),
                                              _buildTextFieldBox(
                                                controller: colorController,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .deny(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                ],
                                                isError: _mostrarErrores &&
                                                    colorController.text
                                                        .trim()
                                                        .isEmpty,
                                                icon:
                                                    Icons.color_lens_rounded,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Sexo y esterilizado
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Sexo:',
                                                isError: _mostrarErrores &&
                                                    sexo == null,
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: "Macho",
                                                    groupValue: sexo,
                                                    activeColor:
                                                        const Color.fromARGB(
                                                      255,
                                                      13,
                                                      0,
                                                      60,
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4,
                                                    ),
                                                    onChanged: (v) => setState(
                                                      () => sexo = v,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Macho",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: "Hembra",
                                                    groupValue: sexo,
                                                    activeColor:
                                                        const Color.fromARGB(
                                                      255,
                                                      13,
                                                      0,
                                                      60,
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4,
                                                    ),
                                                    onChanged: (v) => setState(
                                                      () => sexo = v,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Hembra",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10), // 🔹 menos espacio
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Esterilizado:',
                                                isError: _mostrarErrores &&
                                                    esterilizado == null,
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: "Sí",
                                                    groupValue: esterilizado,
                                                    activeColor:
                                                        const Color.fromARGB(
                                                      255,
                                                      13,
                                                      0,
                                                      60,
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4,
                                                    ),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          esterilizado = v,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Sí",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: "No",
                                                    groupValue: esterilizado,
                                                    activeColor:
                                                        const Color.fromARGB(
                                                      255,
                                                      13,
                                                      0,
                                                      60,
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4,
                                                    ),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          esterilizado = v,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "No",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Tamaño y peso
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Tamaño:',
                                                isError: _mostrarErrores &&
                                                    tamanoController.text
                                                        .trim()
                                                        .isEmpty,
                                              ),
                                              _buildTextFieldBox(
                                                controller: tamanoController,
                                                hintText:
                                                    'Pequeño, mediano, grande...',
                                                hintStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .deny(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                ],
                                                isError: _mostrarErrores &&
                                                    tamanoController.text
                                                        .trim()
                                                        .isEmpty,
                                                icon: Icons
                                                    .straighten_rounded,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10), // 🔹 menos espacio
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLabel(
                                                'Peso:',
                                                isError: _mostrarErrores &&
                                                    pesoController.text
                                                        .trim()
                                                        .isEmpty,
                                              ),
                                              _buildTextFieldBox(
                                                controller: pesoController,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(
                                                      r'^\d{0,3}(\.\d{0,2})?$',
                                                    ),
                                                  ),
                                                ],
                                                suffixText: 'kg',
                                                isError: _mostrarErrores &&
                                                    pesoController.text
                                                        .trim()
                                                        .isEmpty,
                                                icon: Icons
                                                    .monitor_weight_outlined,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // Botones
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _guardarMascota,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                255,
                                                13,
                                                0,
                                                60,
                                              ),
                                              minimumSize:
                                                  const Size.fromHeight(48),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                              minimumSize:
                                                  const Size.fromHeight(48),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Helpers de UI ----------

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
    String? hintText,
    TextStyle? hintStyle,
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
              icon != null ? Icon(icon, size: 20, color: Colors.grey[700]) : null,
          border: InputBorder.none,
          suffixText: suffixText,
          hintText: hintText,
          hintStyle: hintStyle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
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
        items: items
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
    final bool isError =
        _mostrarErrores && razaController.text.trim().isNotEmpty == false;

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

    return _buildTextFieldBox(
      controller: razaController,
      isError: isError,
      icon: Icons.pets_outlined,
    );
  }

  Widget _buildEdadField() {
    final bool isError = _mostrarErrores && edadController.text.trim().isEmpty;

    final borderColor =
        isError ? Colors.red : const Color(0xFF2A74D9).withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: edadController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,2}(\.\d{0,2})?$'),
                ),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _unidadEdad,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'años', child: Text('años')),
                  DropdownMenuItem(value: 'meses', child: Text('meses')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _unidadEdad = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
