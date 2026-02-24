import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class EditarMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;
  final Map<String, dynamic> mascotaData;

  const EditarMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
    required this.mascotaData,
  });

  @override
  State<EditarMascota> createState() => _EditarMascotaState();
}

class _EditarMascotaState extends State<EditarMascota> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final edadController = TextEditingController();
  final razaController = TextEditingController();
  final tamanoController = TextEditingController();
  final pesoController = TextEditingController();
  final colorController = TextEditingController();

  String? especie;
  String? sexo;
  bool? esterilizado;
  String _unidadEdad = "años";

  File? _imagen;
  String? _fotoUrlRemota;

  @override
  void initState() {
    super.initState();

    final data = widget.mascotaData;

    nombreController.text = data['nombre'] ?? '';
    razaController.text = data['raza'] ?? '';
    tamanoController.text = data['tamano'] ?? '';
    pesoController.text = data['peso'] ?? '';
    colorController.text = data['color'] ?? '';

    especie = data['especie'];
    sexo = data['sexo'];
    //esterilizado = data['esterilizado'] as bool?; DESPUES DE ELIMINAR REGISTROS PREVIOS HABILITO ESTA LINEA
    final est = data['esterilizado'];

    if (est is bool) {
      esterilizado = est;
    } else if (est is String) {
      esterilizado = est == "Sí";
    }
    _fotoUrlRemota = data['fotoUrl'];

    if (data['edad'] != null) {
      final partes = data['edad'].toString().split(' ');
      edadController.text = partes[0];
      if (partes.length > 1) {
        _unidadEdad = partes[1];
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = nombreController.text.trim();
    final edad = edadController.text.trim();
    final raza = razaController.text.trim();
    final tamano = tamanoController.text.trim();
    final peso = pesoController.text.trim();
    final color = colorController.text.trim();

    final clienteRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId);

    final mascotaRef = clienteRef.collection('mascotas').doc(widget.mascotaId);

    await mascotaRef.update({
      'nombre': nombre,
      'edad': '$edad $_unidadEdad',
      'raza': raza,
      'tamano': tamano,
      'peso': peso,
      'color': color,
      'especie': especie,
      'sexo': sexo,
      'esterilizado': esterilizado,
      'fotoUrl': _fotoUrlRemota,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota actualizada correctamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1446),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1446),
        elevation: 0,
        title: const Text("Editar Mascota"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// FOTO
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _imagen != null
                            ? FileImage(_imagen!)
                            : (_fotoUrlRemota != null
                                ? NetworkImage(_fotoUrlRemota!)
                                : const AssetImage("assets/images/icono.png")
                                    as ImageProvider),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildInput(nombreController, "Nombre"),
              _buildInput(
                edadController,
                "Edad",
                keyboardType: TextInputType.number,
              ),
              _buildInput(razaController, "Raza"),
              _buildInput(tamanoController, "Tamaño"),
              _buildInput(
                pesoController,
                "Peso",
                keyboardType: TextInputType.number,
              ),
              _buildInput(colorController, "Color"),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B1446),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: _guardarCambios,
                child: const Text(
                  "Actualizar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            (value) =>
                value == null || value.isEmpty ? "Campo obligatorio" : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
