import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/Mascota_vet.dart'; // PerfilMascota
import 'package:login/Pantallas/registrar_mascota.dart'; // RegistrarMascota

class Cliente extends StatelessWidget {
  final String clienteId;
  const Cliente({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clienteRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId);

    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width < 360 ? 12 : 16;

    return Scaffold(
      // fondo base lila suave
      backgroundColor: const Color(0xFFD7D2FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // barra con degradado azul como la imagen
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF67A8FF), // azul claro arriba
                Color(0xFF2464EB), // azul más intenso abajo
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Perfil del cliente',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7D2FF), Color(0xFFF1EEFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  24,
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: clienteRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error al cargar datos del cliente'),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] ?? 'Cliente';
                    final direccion = data['direccion'] ?? 'Sin dirección';
                    final telefono = data['telefono'] ?? 'Sin teléfono';

                    return _CardContenido(
                      theme: theme,
                      nombre: nombre,
                      direccion: direccion,
                      telefono: telefono,
                      clienteId: clienteId,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContenido extends StatelessWidget {
  const _CardContenido({
    required this.theme,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.clienteId,
  });

  final ThemeData theme;
  final String nombre;
  final String direccion;
  final String telefono;
  final String clienteId;

  @override
  Widget build(BuildContext context) {
    final mascotasRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId)
        .collection('mascotas');

    const moradoOscuro = Color(0xFF0B1446);
    const azulChip = Color(0xFF5F79FF);

    final width = MediaQuery.of(context).size.width;
    final double cardRadius = width < 360 ? 22 : 28;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado cliente
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: azulChip.withOpacity(.5), width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFEDEFF3),
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: moradoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: azulChip.withOpacity(.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.pets, size: 14, color: azulChip),
                          SizedBox(width: 4),
                          Text(
                            'Cliente PetCare',
                            style: TextStyle(
                              fontSize: 11,
                              color: azulChip,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Divider(height: 1),

          const SizedBox(height: 18),
          const Text(
            'Información de contacto',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          _PillInfo(
            icon: Icons.home_filled,
            label: 'Dirección',
            text: direccion,
          ),
          const SizedBox(height: 10),
          _PillInfo(
            icon: Icons.phone_rounded,
            label: 'Teléfono',
            text: telefono,
          ),

          const SizedBox(height: 24),
          const Text(
            'Mascotas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: mascotasRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error al cargar mascotas');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: azulChip.withOpacity(.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Este cliente aún no tiene mascotas registradas.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      _BotonAgregarMascota(clienteId: clienteId),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        if (index == docs.length) {
                          return _BotonAgregarMascota(clienteId: clienteId);
                        }

                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final nombreMascota = data['nombre'] ?? 'Mascota';

                        final dynamic fotoDynamic =
                            data['fotoUrl'] ?? data['foto'];
                        final String? fotoUrl =
                            fotoDynamic is String && fotoDynamic.isNotEmpty
                                ? fotoDynamic
                                : null;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => PerfilMascota(
                                      clienteId: clienteId,
                                      mascotaId: doc.id,
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: azulChip,
                                    width: 2.4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      fotoUrl != null
                                          ? NetworkImage(fotoUrl)
                                          : const AssetImage(
                                                'assets/images/perro.jpg',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  nombreMascota,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  const _PillInfo({
    required this.icon,
    required this.text,
    required this.label,
  });

  final IconData icon;
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    const azulChip = Color(0xFF5F79FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: azulChip.withOpacity(.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: azulChip.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: azulChip),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAgregarMascota extends StatelessWidget {
  const _BotonAgregarMascota({required this.clienteId});
  final String clienteId;

  @override
  Widget build(BuildContext context) {
    const moradoOscuro = Color(0xFF0B1446);
    const azulChip = Color(0xFF5F79FF);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegistrarMascota(clienteId: clienteId),
              ),
            );
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [moradoOscuro, azulChip],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 6),
        const SizedBox(
          width: 80,
          child: Text(
            'Añadir\nMascota',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
