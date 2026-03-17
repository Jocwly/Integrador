import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? _fotoUrlRemota;
  bool _cargando = false;

  final ImagePicker _picker = ImagePicker();

  static const String cloudName = 'dsjyywplr';
  static const String uploadPreset = 'mascots';

  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imagen = File(picked.path);
      });
    }
  }

  Future<String?> _subirImagenACloudinary(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      return responseData['secure_url'];
    } else {
      return null;
    }
  }

  // 🔥 Extra: eliminar imagen anterior
  Future<void> _eliminarImagenAnterior(String url) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );

      // ⚠️ Necesitas el public_id (lo sacamos de la URL)
      final publicId = url.split('/').last.split('.').first;

      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'upload_preset': uploadPreset, // opcional según config
        },
      );

      if (response.statusCode != 200) {
        debugPrint("No se pudo eliminar imagen anterior");
      }
    } catch (e) {
      debugPrint("Error eliminando imagen: $e");
    }
  }

  Future<void> _guardarFoto() async {
    if (_imagen == null) return;

    setState(() => _cargando = true);

    try {
      final url = await _subirImagenACloudinary(_imagen!);

      if (url == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen')),
        );
        setState(() => _cargando = false);
        return;
      }

      // 🔥 eliminar anterior si existe
      if (widget.fotoActual != null && widget.fotoActual!.isNotEmpty) {
        await _eliminarImagenAnterior(widget.fotoActual!);
      }

      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('mascotas')
          .doc(widget.mascotaId)
          .update({'fotoUrl': url});

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    }

    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarImage =
        _imagen != null
            ? FileImage(_imagen!)
            : (_fotoUrlRemota != null
                ? NetworkImage(_fotoUrlRemota!)
                : widget.fotoActual != null
                ? NetworkImage(widget.fotoActual!)
                : const AssetImage("assets/images/icono.png"));

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Foto")),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 60, backgroundImage: avatarImage),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _seleccionarImagen,
                child: const Text("Cambiar Foto"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _guardarFoto,
                child: const Text("Guardar"),
              ),
            ],
          ),

          // 🔄 LOADER
          if (_cargando)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
