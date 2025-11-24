import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/perfil_cliente.dart'; // Cliente

class Clientes extends StatelessWidget {
  const Clientes({super.key});

  @override
  Widget build(BuildContext context) {
    final clientesRef = FirebaseFirestore.instance.collection('clientes');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              clientesRef.orderBy('createdAt', descending: false).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar clientes'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No hay clientes registrados'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final nombre = data['nombre'] ?? 'Sin nombre';
                final correo = data['correo'] ?? 'Sin correo';
                final mascotas = (data['mascotas'] ?? 0) as int;

                return Dismissible(
                  key: Key(doc.id),
                  direction:
                      DismissDirection
                          .endToStart, // deslizar de derecha a izquierda
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // Confirmación antes de borrar
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Eliminar cliente'),
                          content: Text(
                            '¿Seguro que quieres eliminar al cliente "$nombre"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      // Eliminar cliente
                      await clientesRef.doc(doc.id).delete();
                      // Opcional: mostrar mensaje
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cliente "$nombre" eliminado')),
                      );
                    } catch (e, stack) {
                      // Si algo falla, mostramos error
                      debugPrint("ERROR AL ELIMINAR: $e");
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Cliente(
                                clienteId: doc.id, // pasamos el id
                              ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  correo,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$mascotas mascota(s)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}
