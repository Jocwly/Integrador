import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/form_styles.dart';

class ListaPersonal extends StatefulWidget {
  const ListaPersonal({super.key});

  @override
  State<ListaPersonal> createState() => _ListaPersonalState();
}

class _ListaPersonalState extends State<ListaPersonal> {
  final CollectionReference personalRef = FirebaseFirestore.instance.collection(
    'personal',
  );

  // 🔴 ELIMINAR
  void _eliminarPersonal(String id) async {
    final confirmar = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Eliminar"),
            content: const Text("¿Deseas eliminar este integrante?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Eliminar"),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await personalRef.doc(id).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Eliminado correctamente")));
    }
  }

  // 🔵 EDITAR (VENTANA)
  void _mostrarDialogoEditar(DocumentSnapshot data) {
    final nombreCtrl = TextEditingController(text: data['nombre']);
    final correoCtrl = TextEditingController(text: data['correo']);
    final telefonoCtrl = TextEditingController(text: data['telefono']);
    String rolSeleccionado = data['rol'];

    final id = data.id;

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
                    'Editar integrante',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 20),

                  _inputEstilizado(
                    controller: nombreCtrl,
                    label: 'Nombre',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  _inputEstilizado(
                    controller: correoCtrl,
                    label: 'Correo',
                    icon: Icons.email_rounded,
                    keyboard: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  _inputEstilizado(
                    controller: telefonoCtrl,
                    label: 'Teléfono',
                    icon: Icons.phone_rounded,
                    keyboard: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    items:
                        ['Veterinario', 'Asistente']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      rolSeleccionado = value!;
                    },
                    decoration: FormStyles.dropdownDecoration("Rol"),
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
                          final nombre = nombreCtrl.text.trim();
                          final correo = correoCtrl.text.trim();
                          final telefono = telefonoCtrl.text.trim();

                          if (nombre.isEmpty || correo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Nombre y correo son obligatorios",
                                ),
                              ),
                            );
                            return;
                          }

                          await personalRef.doc(id).update({
                            'nombre': nombre,
                            'correo': correo,
                            'telefono': telefono,
                            'rol': rolSeleccionado,
                          });

                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Actualizado correctamente"),
                            ),
                          );
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
    const azulSuave = Color(0xFFD6E1F7);

    return Scaffold(
      backgroundColor: FormStyles.fondo,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Equipo registrado',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔷 ENCABEZADO
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: azulSuave,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group, color: FormStyles.azulFuerte),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Equipo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Listado de integrantes registrados",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔥 LISTA
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    personalRef
                        .orderBy('fechaRegistro', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No hay integrantes registrados"),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      final nombre = data['nombre'] ?? '';
                      final correo = data['correo'] ?? '';
                      final telefono = data['telefono'] ?? '';
                      final rol = data['rol'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),

                        decoration: FormStyles.personalCardDecoration,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: FormStyles.azulFuerte,
                                ),
                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _chipDato(Icons.email, "Correo", correo),
                            _chipDato(Icons.phone, "Teléfono", telefono),
                            _chipDato(Icons.badge, "Rol", rol),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _mostrarDialogoEditar(data),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Color(0xFF2A74D9),
                                  ),
                                  label: const Text(
                                    "Editar",
                                    style: TextStyle(
                                      color: FormStyles.azulFuerte,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _eliminarPersonal(data.id),
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Eliminar",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _chipDato(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: FormStyles.chipDecoration,

      child: Row(
        children: [
          Icon(icon, size: 18, color: FormStyles.azulFuerte),
          const SizedBox(width: 8),

          Text("$label: ", style: FormStyles.chipLabel),

          Expanded(child: Text(value, style: FormStyles.chipValue)),
        ],
      ),
    );
  }
}
