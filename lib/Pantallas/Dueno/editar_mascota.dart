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
  File? _imagenSeleccionada;
  String? _fotoUrlRemota;
  bool _cargando = false;

  final ImagePicker _picker = ImagePicker();

  static const String cloudName = 'dsjyywplr';
  static const String uploadPreset = 'mascots';

  @override
  void initState() {
    super.initState();
    _fotoUrlRemota = widget.fotoActual; // 🔥 importante
  }

  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<String?> _subirImagenACloudinary(File imageFile) async {
    try {
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
      final responseString = await response.stream.bytesToString();

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: $responseString");

      if (response.statusCode == 200) {
        final data = json.decode(responseString);
        return data['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("ERROR SUBIDA: $e");
      return null;
    }
  }

  Future<void> _guardarFoto() async {
    setState(() => _cargando = true);

    try {
      String? fotoUrl = _fotoUrlRemota;

      // 🔥 MISMA LÓGICA QUE TU REGISTRO
      if (_imagenSeleccionada != null) {
        final url = await _subirImagenACloudinary(_imagenSeleccionada!);

        if (url == null) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );

          setState(() => _cargando = false);
          return;
        }

        fotoUrl = url;
        _fotoUrlRemota = url;
      }

      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('mascotas')
          .doc(widget.mascotaId)
          .update({'fotoUrl': fotoUrl});

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto actualizada')));

      Navigator.pop(context);
    } catch (e) {
      debugPrint("ERROR GENERAL: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? avatarImage =
        _imagenSeleccionada != null
            ? FileImage(_imagenSeleccionada!)
            : (_fotoUrlRemota != null && _fotoUrlRemota!.startsWith('https'))
            ? NetworkImage(_fotoUrlRemota!)
            : const AssetImage("assets/images/icono.png");

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Foto")),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: avatarImage,
                    child:
                        avatarImage == null
                            ? const Icon(Icons.add_a_photo, size: 30)
                            : null,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _guardarFoto,
                  child: const Text("Guardar"),
                ),
              ],
            ),
          ),

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
