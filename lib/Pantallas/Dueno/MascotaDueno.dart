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

  void _mostrarDialogoEditar(String direccion, String telefono, String correo) {
    _direccionController.text = direccion;
    _telefonoController.text = telefono;
    _correoController.text = correo;

    const azulPrincipal = Color(0xFF4E78FF);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: azulPrincipal,
                          elevation: 4,
                        ),
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
            PopupMenuButton<int>(
              tooltip: 'Menú',
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value) {
                if (value == 1) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem<int>(
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Cuenta',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
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
                child: Icon(Icons.person_outline, color: Colors.white),
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
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

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
            final direccion = data['direccion'] ?? 'Sin dirección';
            final telefono = data['telefono'] ?? 'Sin teléfono';
            final correo = data['correo'] ?? 'Sin correo';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _banner(nombre),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Información de Contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _mostrarDialogoEditar(direccion, telefono, correo);
                        },
                      ),
                    ],
                  ),

                  _cardContacto(
                    direccion: direccion,
                    telefono: telefono,
                    correo: correo,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Mis Mascotas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 12),

                  _listaMascotas(),
                ],
              ),
            );
          },
        ),
      ),
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
              'assets/images/animales.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardContacto({
    required String direccion,
    required String telefono,
    required String correo,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pillInfo(Icons.home_filled, 'Dirección', direccion),
          const SizedBox(height: 10),
          _pillInfo(Icons.phone_rounded, 'Teléfono', telefono),
          const SizedBox(height: 10),
          _pillInfo(Icons.email_rounded, 'Correo', correo),
        ],
      ),
    );
  }

  Widget _pillInfo(IconData icon, String label, String text) {
    const azulChip = Color(0xFF5F79FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: azulChip.withOpacity(.25)),
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

  Widget _inputEstilizado({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    const azul = Color(0xFF5F79FF);

    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF4F6FF),
        prefixIcon: Icon(icon, color: azul),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: azul.withOpacity(.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: azul.withOpacity(.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: azul, width: 1.5),
        ),
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
