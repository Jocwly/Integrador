import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/form_styles.dart';

class MedicamentosMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const MedicamentosMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<MedicamentosMascota> createState() => _MedicamentosMascotaState();
}

class _MedicamentosMascotaState extends State<MedicamentosMascota> {
  DateTime fechaSeleccionada = DateTime.now();

  bool _matchFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return false;

    DateTime date = DateFormat('dd/MM/yyyy').parse(fecha);

    return DateUtils.isSameDay(date, fechaSeleccionada);
  }

  @override
  Widget build(BuildContext context) {
    final consultasRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId)
        .collection('consultas')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Medicamentos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        centerTitle: true,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3E6FB6), Color(0xFF1E3A6D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: FormStyles.backgroundGradient,
        ),

        child: Column(
          children: [
            _selectorFecha(),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: consultasRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List medicamentos = [];
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data();

                    if (data['medicaciones'] != null) {
                      List meds = data['medicaciones'];

                      for (int i = 0; i < meds.length; i++) {
                        var med = meds[i];

                        if (med['tomas'] != null) {
                          for (int j = 0; j < med['tomas'].length; j++) {
                            var toma = med['tomas'][j];

                            DateTime fechaToma =
                                (toma['fecha'] as Timestamp).toDate();

                            if (DateUtils.isSameDay(
                              fechaToma,
                              fechaSeleccionada,
                            )) {
                              medicamentos.add({
                                "nombre": med['nombre'],
                                "dosis": med['dosis'],
                                "frecuenciaHoras":
                                    med['frecuenciaHoras'], // 👈 AGREGA ESTO
                                "fecha": DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(fechaToma),
                                "fechaReal":
                                    fechaToma, // 👈 importante para validación después
                                "administrado": toma['administrado'] ?? false,
                                "consultaId": doc.id,
                                "medIndex": i,
                                "tomaIndex": j,
                              });
                            }
                          }
                        }
                      }
                    }
                  }

                  if (medicamentos.isEmpty) {
                    return const Center(
                      child: Text("No hay medicamentos para esta fecha"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicamentos.length,
                    itemBuilder: (context, index) {
                      final med = medicamentos[index];

                      return _medCard(med);
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

  /// SELECTOR DE FECHA
  Widget _selectorFecha() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F6FD8), Color(0xFF1B2E7B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(.15),
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Fecha de seguimiento",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 4),

              Text(
                DateFormat('dd/MM/yyyy').format(fechaSeleccionada),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 28,
            ),

            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: fechaSeleccionada,
                firstDate: DateTime(2023),
                lastDate: DateTime(2035),
              );

              if (picked != null) {
                setState(() {
                  fechaSeleccionada = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  /// CARD MEDICAMENTO
  ///
  Widget _medCard(Map med) {
    DateTime ahora = DateTime.now();
    DateTime fechaToma = med["fechaReal"];

    bool puedeMarcar = ahora.isAfter(fechaToma);
    bool administrado = med["administrado"];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: administrado ? Colors.green : const Color(0xFF2A74D9),
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(.05),
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF2A74D9),
                    child: Icon(
                      Icons.medication,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "frecuencia: Cada ${med['frecuenciaHoras']}h",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              _estadoChip(administrado),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            med["nombre"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 4),

          Text(
            "Dosis: ${med["dosis"]}",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF2A74D9)),
              const SizedBox(width: 6),
              Text(med["fecha"]),
            ],
          ),

          const SizedBox(height: 14),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),

            child:
                administrado
                    ? Container(
                      key: const ValueKey("done"),

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Row(
                        children: [
                          Icon(Icons.check, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Administrado"),
                        ],
                      ),
                    )
                    : SizedBox(
                      key: const ValueKey("btn"),

                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF2A74D9),
                        ),

                        onPressed:
                            puedeMarcar
                                ? () async {
                                  final docRef = FirebaseFirestore.instance
                                      .collection('clientes')
                                      .doc(widget.clienteId)
                                      .collection('mascotas')
                                      .doc(widget.mascotaId)
                                      .collection('consultas')
                                      .doc(med["consultaId"]);

                                  final doc = await docRef.get();

                                  var medsData = doc['medicaciones'];

                                  if (medsData is! List) return;

                                  List meds = medsData;

                                  int medIndex = med["medIndex"];
                                  int tomaIndex = med["tomaIndex"];

                                  meds[medIndex]['tomas'][tomaIndex]['administrado'] =
                                      true;

                                  await docRef.update({'medicaciones': meds});
                                }
                                : null, // 👈 DESHABILITA

                        label: const Text(
                          "Marcar como administrado",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _estadoChip(bool administrado) {
    if (administrado) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "completada",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "pendiente",
        style: TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
