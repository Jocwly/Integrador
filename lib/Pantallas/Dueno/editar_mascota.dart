import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;
  final String? fotoActual;

  const EditarMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
    this.fotoActual,
  });

  @override
  State<EditarMascota> createState() => _EditarMascotaState();
}

class _EditarMascotaState extends State<EditarMascota> {
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imagen = File(picked.path);
      });
    }
  }

  Future<void> _guardarFoto() async {
    if (_imagen == null) return;

    // Aquí subirías la imagen a Firebase Storage
    // y obtendrías la nueva URL

    String nuevaUrl = "URL_DE_LA_IMAGEN_SUBIDA";

    await FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId)
        .update({'fotoUrl': nuevaUrl});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Foto")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
                _imagen != null
                    ? FileImage(_imagen!)
                    : widget.fotoActual != null
                    ? NetworkImage(widget.fotoActual!)
                    : const AssetImage("assets/images/icono.png")
                        as ImageProvider,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _seleccionarImagen,
            child: const Text("Cambiar Foto"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _guardarFoto, child: const Text("Guardar")),
        ],
      ),
    );
  }
}
