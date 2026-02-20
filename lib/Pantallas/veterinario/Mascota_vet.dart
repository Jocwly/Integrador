import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/veterinario/citas.dart';
import 'package:login/Pantallas/veterinario/consulta.dart';
import 'package:login/Pantallas/veterinario/historial_medico.dart';
import 'package:login/Pantallas/veterinario/programar_citas.dart';
import 'package:login/Pantallas/veterinario/registro_vacuna.dart';
import 'package:login/Pantallas/veterinario/visualizar_vacunas.dart';

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
      backgroundColor: const Color.fromARGB(255, 151, 151, 151),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_sharp, color: Colors.white),
            SizedBox(width: 6),
            Text(
              "Perfil Mascota",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: mascotaRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _CardMascota(
                      nombre: data['nombre'] ?? '',
                      raza: data['raza'] ?? '',
                      color: data['color'] ?? '',
                      fotoUrl: data['fotoUrl'],
                      clienteId: clienteId,
                      mascotaId: mascotaId,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardMascota extends StatelessWidget {
  final String nombre;
  final String raza;
  final String color;
  final String? fotoUrl;
  final String clienteId;
  final String mascotaId;

  const _CardMascota({
    required this.nombre,
    required this.raza,
    required this.color,
    required this.fotoUrl,
    required this.clienteId,
    required this.mascotaId,
  });

  void _mostrarMenuVacunas(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Vacunas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MenuItem(
                      icon: Icons.vaccines_outlined,
                      label: "Registrar\nvacuna",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RegistrarVacuna(
                                  clienteId: clienteId,
                                  mascotaId: mascotaId,
                                ),
                          ),
                        );
                      },
                    ),

                    _MenuItem(
                      icon: Icons.visibility,
                      label: "Visualizar\nvacunas",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => VisualizarVacunas(
                                  clienteId: clienteId,
                                  mascotaId: mascotaId,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulChip = Color(0xFF5F79FF);
    const moradoOscuro = Color(0xFF0B1446);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundImage:
                fotoUrl != null
                    ? NetworkImage(fotoUrl!)
                    : const AssetImage("assets/images/icono.png")
                        as ImageProvider,
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: moradoOscuro,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(nombre, style: const TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MenuItem(
                icon: Icons.pets,
                label: "Citas",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CitasMascota(
                            clienteId: clienteId,
                            mascotaId: mascotaId,
                          ),
                    ),
                  );
                },
              ),

              _MenuItem(
                icon: Icons.calendar_month,
                label: "Programar citas",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProgramarCita(
                            clienteId: clienteId,
                            mascotaId: mascotaId,
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
              _MenuItem(
                icon: Icons.vaccines,
                label: "Vacunas",
                onTap: () => _mostrarMenuVacunas(context),
              ),

              _MenuItem(
                icon: Icons.medical_services_outlined,
                label: "Consulta médica",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ConsultaMedica(
                            clienteId: clienteId,
                            mascotaId: mascotaId,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MenuItem(
                icon: Icons.assignment_outlined,
                label: "Historial\nMédico",
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const azulChip = Color(0xFF5F79FF);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: azulChip, width: 2),
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
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
