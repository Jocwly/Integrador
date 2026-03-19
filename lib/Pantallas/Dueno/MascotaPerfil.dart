import 'dart:io';
import 'package:flutter/material.dart';
import 'package:login/Pantallas/Dueno/Medicamentos.dart';
import 'package:login/Pantallas/veterinario/citas.dart';
import 'package:login/Pantallas/veterinario/historial_medico.dart';
import 'package:login/Pantallas/Dueno/Alimentacion.dart';
import 'package:login/Pantallas/veterinario/visualizar_vacunas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MascotaPerfil extends StatefulWidget {
  final Map<String, dynamic> mascotaData;
  final String clienteId;
  final String mascotaId;

  const MascotaPerfil({
    super.key,
    required this.mascotaData,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<MascotaPerfil> createState() => _MascotaPerfilState();
}

class _MascotaPerfilState extends State<MascotaPerfil> {
  File? _imagenSeleccionada;
  String? _fotoUrlRemota;
  bool _cargando = false;
  final ImagePicker _picker = ImagePicker();

  static const String cloudName = 'dsjyywplr';
  static const String uploadPreset = 'mascots';

  @override
  void initState() {
    super.initState();
    _fotoUrlRemota = widget.mascotaData['fotoUrl'];
  }

  // Seleccionar imagen y subir automáticamente
  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
        _cargando = true;
      });

      await _subirYGuardarImagen(_imagenSeleccionada!);

      if (mounted) setState(() => _cargando = false);
    }
  }

  // Subir imagen a Cloudinary
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

  // Subir a Cloudinary y guardar en Firestore
  Future<void> _subirYGuardarImagen(File imagen) async {
    final url = await _subirImagenACloudinary(imagen);

    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al subir la imagen')));
      return;
    }

    _fotoUrlRemota = url;

    await FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId)
        .update({'fotoUrl': url});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto actualizada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarImage =
        _imagenSeleccionada != null
            ? FileImage(_imagenSeleccionada!)
            : (_fotoUrlRemota != null && _fotoUrlRemota!.startsWith('https'))
            ? NetworkImage(_fotoUrlRemota!) as ImageProvider
            : const AssetImage("assets/images/icono.png");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 231, 233),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_sharp, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Perfil Mascota',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color(0xFF1A245A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF2A74D9),
                                  width: 3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage: avatarImage,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _seleccionarImagen,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2A74D9),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        _nombreRaza(),
                        const SizedBox(height: 25),
                        _menu(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🔥 OVERLAY DE CARGA (encima de TODO)
            if (_cargando)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _nombreRaza() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2A74D9),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            widget.mascotaData['nombre'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.mascotaData['raza'] ?? '',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _menu() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _menuItem(
              icon: Icons.pets,
              text: 'Citas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CitasMascota(
                          clienteId: widget.clienteId,
                          mascotaId: widget.mascotaId,
                          soloLectura: true,
                        ),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.assignment_outlined,
              text: 'Alimentación',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => Alimentacion(
                          clienteId: widget.clienteId,
                          mascotaId: widget.mascotaId,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _menuItem(
              icon: Icons.medication_liquid_sharp,
              text: 'Medicación',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => MedicamentosMascota(
                          clienteId: widget.clienteId,
                          mascotaId: widget.mascotaId,
                        ),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.vaccines_outlined,
              text: 'Vacunas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => VisualizarVacunas(
                          clienteId: widget.clienteId,
                          mascotaId: widget.mascotaId,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 26),
        _menuItem(
          icon: Icons.assignment_outlined,
          text: 'Historial Médico',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => HistorialMedico(
                      clienteId: widget.clienteId,
                      mascotaId: widget.mascotaId,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A74D9), width: 2),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 34, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
