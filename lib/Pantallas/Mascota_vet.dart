import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/citas.dart';
import 'package:login/Pantallas/consulta.dart';
import 'package:login/Pantallas/historial_medico.dart';
import 'package:login/Pantallas/programar_citas.dart';
import 'package:login/Pantallas/registro_vacuna.dart';

class PerfilMascota extends StatelessWidget {
  final String clienteId;
  final String mascotaId;

  const PerfilMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId)
        .collection('mascotas')
        .doc(mascotaId);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Mi Mascota',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: mascotaRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar datos de la mascota'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = data['nombre'] ?? 'Mascota';
          final raza = data['raza'] ?? '';
          final color = data['color'] ?? '';

          // 👇 Soporte para fotoUrl (nuevo) y foto (antiguo)
          final dynamic fotoDynamic = data['fotoUrl'] ?? data['foto'];
          final String? fotoUrl =
              fotoDynamic is String && fotoDynamic.isNotEmpty
                  ? fotoDynamic
                  : null;

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Imagen circular de la mascota
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 13, 0, 60),
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: fotoUrl != null
                            ? NetworkImage(fotoUrl)
                            : const AssetImage('assets/images/perro.jpg')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nombre real
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 13, 0, 60),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (raza.isNotEmpty || color.isNotEmpty)
                      Text(
                        [raza, color].where((e) => e.isNotEmpty).join(' • '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Tarjeta con botones
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMenuItem(
                                icon: Icons.pets,
                                label: "Citas",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CitasMascota(
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.calendar_month,
                                label: "Programar citas",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProgramarCita(
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMenuItem(
                                icon: Icons.vaccines,
                                label: "Vacunas",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegistrarVacuna(
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.medical_services_outlined,
                                label: "Consulta médica",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConsultaMedica(
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMenuItem(
                                icon: Icons.assignment_outlined,
                                label: "Historial\nMédico",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistorialMedico(
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A74D9), width: 1.8),
            ),
            child: Icon(icon, color: Colors.black, size: 34),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
