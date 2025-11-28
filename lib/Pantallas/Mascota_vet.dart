import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/citas.dart';
import 'package:login/Pantallas/consulta.dart';
import 'package:login/Pantallas/historial_medico.dart';
import 'package:login/Pantallas/programar_citas.dart';
import 'package:login/Pantallas/registro_vacuna.dart';

// =======================
//   APPBAR PERSONALIZADO
// =======================
class GradientTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final VoidCallback onBack;

  const GradientTopBar({
    super.key,
    required this.title,
    required this.icon,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6FA8FF), // azul claro
            Color(0xFF2F64E0), // azul fuerte
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 26,
              ),
              onPressed: onBack,
            ),

            const Spacer(),

            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const Spacer(),

            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// =======================
//   PERFIL MASCOTA
// =======================

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

      // NUEVO APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color.fromARGB(255, 26, 36, 90)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets_sharp, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Perfil Mascota',
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
              child: StreamBuilder<DocumentSnapshot>(
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
                  final dynamic fotoDynamic = data['fotoUrl'] ?? data['foto'];
                  final String? fotoUrl =
                      (fotoDynamic is String && fotoDynamic.isNotEmpty)
                          ? fotoDynamic
                          : null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: _CardMascota(
                      nombre: nombre,
                      raza: raza,
                      color: color,
                      fotoUrl: fotoUrl,
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

// =========================================
//          TARJETA Y MENÚ COMPLETO
// =========================================
// (SIN CAMBIOS — SIGUE IGUAL QUE TU DISEÑO)

class _CardMascota extends StatelessWidget {
  const _CardMascota({
    required this.nombre,
    required this.raza,
    required this.color,
    required this.fotoUrl,
    required this.clienteId,
    required this.mascotaId,
  });

  final String nombre;
  final String raza;
  final String color;
  final String? fotoUrl;
  final String clienteId;
  final String mascotaId;

  @override
  Widget build(BuildContext context) {
    const moradoOscuro = Color(0xFF0B1446);
    const azulChip = Color(0xFF5F79FF);

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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar y nombre igual que tu diseño
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: azulChip, width: 3),
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage:
                      fotoUrl != null
                          ? NetworkImage(fotoUrl!)
                          : const AssetImage("assets/images/perro.jpg")
                              as ImageProvider,
                ),
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: moradoOscuro,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              if (raza.isNotEmpty || color.isNotEmpty)
                Text(
                  [raza, color].where((e) => e.isNotEmpty).join(" · "),
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: azulChip.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.pets, size: 14, color: azulChip),
                    SizedBox(width: 4),
                    Text(
                      "Paciente",
                      style: TextStyle(fontSize: 11, color: azulChip),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Divider(height: 1),
          const SizedBox(height: 18),
          const SizedBox(height: 12),

          // Grid
          Column(
            children: [
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
                    icon: Icons.vaccines_outlined,
                    label: "Vacunas",
                    onTap: () {
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
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
