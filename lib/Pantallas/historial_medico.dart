import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/Pantallas/detalles_hm.dart';

class HistorialMedico extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const HistorialMedico({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  _HistorialMedicoState createState() => _HistorialMedicoState();
}

class _HistorialMedicoState extends State<HistorialMedico> {
  String? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    final consultasRef = mascotaRef.collection('consultas');

    final azulClaro = const Color(0xffe6e8ff);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Color(0xFF2A74D9),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Historial Médico',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: mascotaRef.snapshots(),
        builder: (context, mascotaSnapshot) {
          if (mascotaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!mascotaSnapshot.hasData || !mascotaSnapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró información de la mascota'),
            );
          }

          final mascotaData =
              mascotaSnapshot.data!.data() as Map<String, dynamic>;
          final nombre = mascotaData['nombre'] ?? 'Sin nombre';
          final especie = mascotaData['especie'] ?? '---';
          final raza = mascotaData['raza'] ?? '---';
          final edad = mascotaData['edad'] ?? '---';
          final sexo = mascotaData['sexo'] ?? '---';
          final fotoUrl = mascotaData['fotoUrl'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: azulClaro,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            fotoUrl != null
                                ? Image.network(
                                  fotoUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/images/perro.jpg',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nombre: $nombre",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Especie: $especie"),
                            Text("Raza: $raza"),
                            Text("Edad: $edad años"),
                            Text("Sexo: $sexo"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Seleccionar fecha",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                initialDate: DateTime.now(),
                              );
                              if (picked != null) {
                                String fechaFormateada = DateFormat(
                                  'dd/MM/yyyy',
                                ).format(picked);
                                setState(() {
                                  _selectedDate = fechaFormateada;
                                  _dateController.text = fechaFormateada;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A74D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Buscar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        (_selectedDate == null || _selectedDate!.isEmpty)
                            ? consultasRef
                                .orderBy('fecha', descending: true)
                                .snapshots()
                            : consultasRef
                                .where('fechaStr', isEqualTo: _selectedDate)
                                .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No hay resultados para la fecha seleccionada.",
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final consulta =
                              docs[index].data() as Map<String, dynamic>;
                          final consultaId = docs[index].id;

                          DateTime fecha =
                              (consulta['fecha'] as Timestamp).toDate();
                          String fechaFormateada = DateFormat(
                            'dd/MM/yyyy',
                          ).format(fecha);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A74D9).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Fecha: $fechaFormateada",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 34, 34, 34),
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '📌 Motivo: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: consulta['motivo'] ?? '---',
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 34, 34, 34),
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '🩺 Diagnóstico: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: consulta['diagnostico'] ?? '---',
                                      ),
                                    ],
                                  ),
                                ),

                                if (consulta['medicaciones'] != null &&
                                    consulta['medicaciones'] is List) ...[
                                  const Text(
                                    "💊 Medicaciones:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  ...List<Widget>.from(
                                    (consulta['medicaciones'] as List).map((
                                      med,
                                    ) {
                                      return Text(
                                        "• ${med['nombre']} — ${med['dosis']} — ${med['frecuencia']} — ${med['duracion']}",
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    }),
                                  ),
                                ] else
                                  const Text("💊 Medicaciones: ---"),

                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ConsultaMedicaDetalles(
                                                clienteId: widget.clienteId,
                                                mascotaId: widget.mascotaId,
                                                consultaId: consultaId,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A74D9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text(
                                      "DETALLES",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
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
          );
        },
      ),
    );
  }
}
