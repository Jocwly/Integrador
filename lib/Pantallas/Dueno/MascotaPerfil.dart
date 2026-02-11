import 'package:flutter/material.dart';
import 'package:login/Pantallas/veterinario/historial_medico.dart';
import 'package:login/Pantallas/Dueno/Alimentacion.dart';

class MascotaPerfil extends StatelessWidget {
  final Map<String, dynamic> mascotaData;
  final String clienteId;
  final String mascotaId;

  const MascotaPerfil({
    super.key,
    required this.mascotaData,
    required this.clienteId,
    required this.mascotaId, // ✅ agregado
  });

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
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
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage:
                          mascotaData['fotoUrl'] != null
                              ? NetworkImage(mascotaData['fotoUrl'])
                              : null,
                      backgroundColor: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1446),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      mascotaData['nombre'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    mascotaData['raza'] ?? '',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),

                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 22),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _menuItem(
                            icon: Icons.pets,
                            text: 'Citas',
                            onTap: () {
                              Navigator.pushNamed(context, '/citas_dueno');
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
                                        clienteId: clienteId,
                                        mascotaId: mascotaId,
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
                              Navigator.pushNamed(context, '/Vacunas');
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
          ),
        ),
      ),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
