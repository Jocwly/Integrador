import 'dart:io';
import 'package:flutter/material.dart';
import 'package:login/Pantallas/veterinario/citas.dart';
import 'package:login/Pantallas/veterinario/historial_medico.dart';
import 'package:login/Pantallas/Dueno/Alimentacion.dart';
import 'package:login/Pantallas/veterinario/visualizar_vacunas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

class _MascotaPerfilState extends State<MascotaPerfil>
    with SingleTickerProviderStateMixin {
  String? fotoUrl;
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scaleAvatar;

  @override
  void initState() {
    super.initState();
    fotoUrl = widget.mascotaData['fotoUrl'];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAvatar = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cambiarFoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _imagen = File(picked.path);
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('mascotas')
          .child(widget.clienteId)
          .child('${widget.mascotaId}.jpg');

      await ref.putFile(_imagen!);

      final nuevaUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('mascotas')
          .doc(widget.mascotaId)
          .update({'fotoUrl': nuevaUrl});

      setState(() {
        fotoUrl = nuevaUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto actualizada correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al subir la imagen")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEBFF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 20, color: Colors.white),
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
              colors: [
                Color.fromARGB(255, 70, 125, 206),
                Color.fromARGB(255, 18, 41, 95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 26,
                  horizontal: 20,
                ),
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
                      ScaleTransition(
                        scale: _scaleAvatar,
                        child: _avatarWidget(),
                      ),
                      const SizedBox(height: 12),
                      _nombreRaza(),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 22),
                      _menu(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarWidget() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage:
                  _imagen != null
                      ? FileImage(_imagen!)
                      : fotoUrl != null
                      ? NetworkImage(fotoUrl!)
                      : const AssetImage("assets/images/icono.png")
                          as ImageProvider,
            ),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: GestureDetector(
              onTap: _cambiarFoto,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0B1446),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nombreRaza() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1446),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            widget.mascotaData['nombre'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
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
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _menuItem(
              icon: Icons.medication,
              text: 'Medicamentos',
              onTap: () {
                Navigator.pushNamed(context, '/Medicamentos');
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
        const SizedBox(height: 28),
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
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 69,
              width: 69,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 30, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 100,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
