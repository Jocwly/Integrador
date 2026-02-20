import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'MascotaPerfil.dart';

class Mascotadueno extends StatefulWidget {
  static const routeName = '/Mascotadueno';

  final String clienteId;

  const Mascotadueno({super.key, required this.clienteId});

  @override
  State<Mascotadueno> createState() => _MascotaduenoState();
}

class _MascotaduenoState extends State<Mascotadueno> {
  String nombreCliente = '';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  // 🔥 Obtener nombre del cliente desde Firestore
  Future<void> _cargarNombre() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .get();

    if (doc.exists) {
      setState(() {
        nombreCliente = doc['nombre'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
            ),
          ),
        ),

        title: Row(
          children: [
            /// 👤 MENÚ USUARIO
            PopupMenuButton<int>(
              tooltip: 'Menú',
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              /// 🔥 AQUÍ VA LA FUNCIONALIDAD
              onSelected: (value) {
                if (value == 1) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // o Login.routeName si lo usas
                    (route) => false,
                  );
                }
              },

              itemBuilder:
                  (context) => [
                    PopupMenuItem<int>(
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            nombreCliente,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuDivider(),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],

              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            /// ❤️ LOGO PETCARE CENTRADO
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PetCare',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 🔔 NOTIFICACIONES
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              tooltip: 'Notificaciones',
            ),
          ],
        ),
      ),

      // 🐾 CONTENIDO
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 BANNER CON NOMBRE
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF020617)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, $nombreCliente!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cuida de tus mascotas',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/animales.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Mis Mascotas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            // 📦 LISTA DE MASCOTAS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('clientes')
                        .doc(widget.clienteId)
                        .collection('mascotas')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay mascotas registradas'),
                    );
                  }

                  final mascotas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: mascotas.length,
                    itemBuilder: (context, index) {
                      final mascotaDoc = mascotas[index];
                      final data = mascotaDoc.data() as Map<String, dynamic>;

                      final mascotaId = mascotaDoc.id;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MascotaPerfil(
                                    mascotaData: data,
                                    clienteId: widget.clienteId,
                                    mascotaId: mascotaId,
                                  ),
                            ),
                          );
                        },
                        child: _mascotaCard(data),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🐶 TARJETA DE MASCOTA
  // 🐶 TARJETA DE MASCOTA
  Widget _mascotaCard(Map<String, dynamic> data) {
    // 🔹 MISMA LÓGICA QUE EN CLIENTE (vet)
    final String? fotoUrl =
        (data['fotoUrl'] ?? data['foto']) is String
            ? (data['fotoUrl'] ?? data['foto']) as String
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEDEFF3),
            backgroundImage:
                (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? NetworkImage(fotoUrl)
                    : const AssetImage("assets/images/icono.png")
                        as ImageProvider,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nombre'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  data['raza'] ?? '',
                  style: const TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data['edad']} • ${data['peso']} kg',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
