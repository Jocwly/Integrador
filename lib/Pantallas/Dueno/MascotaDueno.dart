import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'MascotaPerfil.dart';
import 'package:login/form_styles.dart';
import 'package:login/servicios/notification_service.dart';

class Mascotadueno extends StatefulWidget {
  static const routeName = '/Mascotadueno';
  final String clienteId;

  const Mascotadueno({super.key, required this.clienteId});

  @override
  State<Mascotadueno> createState() => _MascotaduenoState();
}

class _MascotaduenoState extends State<Mascotadueno> {
  @override
  void initState() {
    super.initState();
    _escucharCitas();
  }

  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  DocumentReference get clienteRef =>
      FirebaseFirestore.instance.collection('clientes').doc(widget.clienteId);

  @override
  void dispose() {
    _direccionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _guardarContacto() async {
    await clienteRef.update({
      'direccion': _direccionController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'correo': _correoController.text.trim(),
    });
  }

  void _escucharCitas() {
    FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .snapshots()
        .listen((mascotasSnapshot) {
          for (var mascota in mascotasSnapshot.docs) {
            final mascotaId = mascota.id;

            FirebaseFirestore.instance
                .collection('clientes')
                .doc(widget.clienteId)
                .collection('mascotas')
                .doc(mascotaId)
                .collection('citas')
                .snapshots()
                .listen((citasSnapshot) {
                  for (var cambio in citasSnapshot.docChanges) {
                    if (cambio.type == DocumentChangeType.added) {
                      final data = cambio.doc.data() as Map<String, dynamic>?;

                      if (data == null || data['fecha'] == null) return;

                      // 🔔 Notificación inmediata
                      NotificationService.mostrarNotificacion(
                        "🐾 Nueva cita",
                        "Tienes una cita de ${data?['tipo']}",
                      );

                      // ⏰ Recordatorio 1 hora antes
                      DateTime fecha = (data?['fecha'] as Timestamp).toDate();

                      NotificationService.programarNotificacion(
                        "⏰ Recordatorio",
                        "Tienes una cita en 1 hora",
                        fecha.subtract(const Duration(hours: 1)),
                      );
                    }
                  }
                });
          }
        });
  }

  void _mostrarDialogoEditar(String direccion, String telefono, String correo) {
    _direccionController.text = direccion;
    _telefonoController.text = telefono;
    _correoController.text = correo;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: FormStyles.dialogShape(),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: FormStyles.dialogDecoration(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Información',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 20),

                  _inputEstilizado(
                    controller: _direccionController,
                    label: 'Dirección',
                    icon: Icons.home_filled,
                  ),

                  const SizedBox(height: 16),

                  _inputEstilizado(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone_rounded,
                    keyboard: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  _inputEstilizado(
                    controller: _correoController,
                    label: 'Correo',
                    icon: Icons.email_rounded,
                    keyboard: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 12),

                      ElevatedButton(
                        style: FormStyles.botonPrincipal(),
                        onPressed: () async {
                          await _guardarContacto();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 231, 233),

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: clienteRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar datos'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final nombre = data['nombre'] ?? 'Cliente';
            final direccion = data['direccion'] ?? '';
            final telefono = data['telefono'] ?? '';
            final correo = data['correo'] ?? '';

            return Column(
              children: [
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      PopupMenuButton<int>(
                        tooltip: 'Menú',
                        offset: const Offset(0, 50),
                        onSelected: (value) {
                          if (value == 1) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          } else if (value == 2) {
                            _mostrarDialogoEditar(direccion, telefono, correo);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem<int>(
                                enabled: false,
                                child: Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 8),
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Editar información'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<int>(
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
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'PetCare',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _banner(nombre),
                        const SizedBox(height: 24),
                        const Text(
                          'Mis Mascotas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _listaMascotas(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _inputEstilizado({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: FormStyles.inputDecorationLabel(label, icon),
    );
  }

  Widget _banner(String nombre) {
    return Container(
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
                  '¡Hola, $nombre!',
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
              'assets/images/animales.jpg',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaMascotas() {
    return StreamBuilder<QuerySnapshot>(
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
          return const Text('No hay mascotas registradas');
        }

        final mascotas = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mascotas.length,
          itemBuilder: (context, index) {
            final mascotaDoc = mascotas[index];
            final data = mascotaDoc.data() as Map<String, dynamic>;

            final mascotaId = mascotaDoc.id;

            return Dismissible(
              key: Key(mascotaId),
              direction: DismissDirection.endToStart, // Solo izquierda
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Eliminar mascota'),
                        content: const Text(
                          '¿Seguro que deseas eliminar esta mascota?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              },
              onDismissed: (direction) async {
                await FirebaseFirestore.instance
                    .collection('clientes')
                    .doc(widget.clienteId)
                    .collection('mascotas')
                    .doc(mascotaId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mascota eliminada')),
                );
              },
              child: GestureDetector(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _mascotaCard(Map<String, dynamic> data) {
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
