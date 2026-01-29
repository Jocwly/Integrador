import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Mascotadueno extends StatelessWidget {
  static const routeName = '/Mascotadueno';

  final String clienteId;

  const Mascotadueno({super.key, required this.clienteId});

  static const Color darkBlue = Color(0xFF081B4D);
  static const Color softBlue = Color(0xFFE9EFFF);
  static const LinearGradient petCareGradient = LinearGradient(
    colors: [
      Color(0xFF081B4D), // azul oscuro
      Color(0xFF1E3A8A), // azul medio
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🟦 AppBar tipo PetCare
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite_border, color: Colors.white, size: 20),
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
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),

      // 📂 Drawer
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color.fromARGB(175, 8, 28, 77),
                    child: Icon(Icons.person, size: 34),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Adriana',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 4, 39),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _item(
                    context,
                    icon: Icons.home,
                    text: 'Inicio',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.vaccines,
                    text: 'Vacunas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Vacunas');
                    },
                  ),

                  _item(
                    context,
                    icon: Icons.event,
                    text: 'Citas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/citas_dueno');
                    },
                    ),
                  _item(
                    context,
                    icon: Icons.medical_information,
                    text: 'Medicamentos',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Medicamentos');
                    },
                    ),
                  _item(
                    context,
                    icon: Icons.pets_outlined,
                    text: 'Alimentación',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Alimentacion');
                    },
                    ),
                  _item(
                    context,
                    icon: Icons.medical_information,
                    text: 'Historial Médico',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Historial_medico');
                    },
                    ),
                ],
              ),
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // 🐾 CONTENIDO
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF020617)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              '¡Hola!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
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
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Mis mascotas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            // 🐶 Tarjetas de mascotas
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('clientes')
                        .doc(clienteId)
                        .collection('mascotas')
                        .orderBy('createdAt', descending: true)
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
                      final data =
                          mascotas[index].data() as Map<String, dynamic>;

                      return _mascotaCardFirestore(data);
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

  // ---------- CARD MASCOTA ----------
  Widget _mascotaCardFirestore(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2563EB),
            backgroundImage:
                data['fotoUrl'] != null ? NetworkImage(data['fotoUrl']) : null,
            child:
                data['fotoUrl'] == null
                    ? const Icon(Icons.favorite, color: Colors.white)
                    : null,
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

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = const Color.fromARGB(255, 0, 0, 0),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }
}
