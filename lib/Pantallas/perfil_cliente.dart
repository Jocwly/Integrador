import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/Mascota_vet.dart';                   // PerfilMascota
import 'package:login/Pantallas/registrar_mascota.dart';  // RegistrarMascota

class Cliente extends StatelessWidget {
  final String clienteId;
  const Cliente({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clienteRef =
        FirebaseFirestore.instance.collection('clientes').doc(clienteId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),

            // Contenido
            Positioned.fill(
              top: 56,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: clienteRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error al cargar datos del cliente'),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
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
          ],
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26), // más redondeado, estilo mockup
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEDEFF3),
              child: Icon(Icons.person, size: 48, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 12),

          // Nombre real
          Center(
            child: Text(
              nombre,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Dirección
          const Text(
            'Dirección:',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          _PillInfo(
            icon: Icons.home_filled,
            text: direccion,
          ),
          const SizedBox(height: 16),

          // Teléfono
          const Text(
            'Teléfono',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          _PillInfo(icon: Icons.phone, text: telefono),
          const SizedBox(height: 22),

          // Mascotas
          const Text(
            'Mascotas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Lista de mascotas + botón añadir (DISEÑO MOCKUP)
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

              // Si no hay mascotas: solo mostrar mensaje + botón añadir
              if (docs.isEmpty) {
                return Column(
                  children: [
                    const Text(
                      'Este cliente aún no tiene mascotas registradas.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _BotonAgregarMascota(clienteId: clienteId),
                  ],
                );
              }

              // Con mascotas: círculos horizontales + añadir al final
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final nombreMascota =
                          data['nombre'] ?? 'Mascota';
                      final foto = data['foto'];

                      return GestureDetector(
                        onTap: () {
                          // MISMA FUNCIONALIDAD: ir al perfil de la mascota
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PerfilMascota(
                                clienteId: clienteId,
                                mascotaId: doc.id,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF7FA3FF),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 34,
                                  backgroundImage: foto != null
                                      ? NetworkImage(foto)
                                      : const NetworkImage(
                                          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=300',
                                        ),
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
                        ),
                      );
                    }).toList(),

                    // Botón añadir mascota en la misma fila
                    _BotonAgregarMascota(clienteId: clienteId),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  const _PillInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EBFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 4.0),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(44),
            onTap: () {
              // MISMA FUNCIONALIDAD DE ANTES: registrar mascota
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegistrarMascota(clienteId: clienteId),
                ),
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7FA3FF),
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const SizedBox(
            width: 80,
            child: Text(
              'Añadir\nMascota',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
