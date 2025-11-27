import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
          final edad =
              mascotaData['edad'] ?? '---'; // ya incluye "años"/"meses"
          final sexo = mascotaData['sexo'] ?? '---';

          // 👇 Soporte para fotoUrl nuevo y foto antiguo
          final dynamic fotoDynamic =
              mascotaData['fotoUrl'] ?? mascotaData['foto'];
          final String? fotoUrl =
              fotoDynamic is String && fotoDynamic.isNotEmpty
                  ? fotoDynamic
                  : null;

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
                            Text("Edad: $edad"), // 👈 sin duplicar "años"
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
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 34, 34, 34),
                                      fontSize: 16,
                                    ),
                                    children: [
                                      const TextSpan(
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
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 34, 34, 34),
                                      fontSize: 16,
                                    ),
                                    children: [
                                      const TextSpan(
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

                                const SizedBox(height: 6),
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
                                      _mostrarReporteConsulta(
                                        context,
                                        consulta,
                                        fechaFormateada,
                                        consultaId,
                                        fecha, // DateTime real
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

  void _mostrarReporteConsulta(
    BuildContext context,
    Map<String, dynamic> consulta,
    String fechaFormateada,
    String consultaId,
    DateTime fechaConsulta,
  ) {
    final Color azulSuave = const Color(0xFFD6E1F7);
    final Color azulFuerte = const Color(0xFF2A74D9);

    final List<dynamic> medsDynamic = consulta['medicaciones'] ?? [];
    final List<Map<String, dynamic>> medicaciones =
        medsDynamic.cast<Map<String, dynamic>>();

    final inicioDia = DateTime(
      fechaConsulta.year,
      fechaConsulta.month,
      fechaConsulta.day,
    );
    final finDia = inicioDia.add(const Duration(days: 1));

    final vacunasQuery = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId)
        .collection('vacunas')
        .where('fechaAplicacion', isGreaterThanOrEqualTo: inicioDia)
        .where('fechaAplicacion', isLessThan: finDia)
        .orderBy('fechaAplicacion', descending: false);

    showDialog(
      context: context,
      builder: (_) {
        final double maxHeight = MediaQuery.of(context).size.height * 0.8;
        final double maxWidth = MediaQuery.of(context).size.width * 0.95;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              maxWidth: maxWidth,
            ),
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del reporte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined, color: azulFuerte),
                          const SizedBox(width: 8),
                          const Text(
                            "Reporte de consulta médica",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fecha de consulta: $fechaFormateada",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // Datos consulta
                  _seccionTitulo(
                    icon: Icons.info_outline,
                    titulo: "Datos de la consulta",
                  ),
                  _datoReporte(
                    "Motivo de consulta",
                    consulta['motivo'] ?? '---',
                    multiline: true,
                  ),

                  const SizedBox(height: 6),
                  _seccionTitulo(
                    icon: Icons.monitor_heart_outlined,
                    titulo: "Signos vitales",
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _chipDetalle(
                          label: "Peso",
                          value:
                              (consulta['peso'] != null &&
                                      consulta['peso'].toString().isNotEmpty)
                                  ? "${consulta['peso']} kg"
                                  : '---',
                          icon: Icons.monitor_weight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _chipDetalle(
                          label: "Temperatura",
                          value:
                              (consulta['temperatura'] != null &&
                                      consulta['temperatura']
                                          .toString()
                                          .isNotEmpty)
                                  ? "${consulta['temperatura']} °C"
                                  : '---',
                          icon: Icons.thermostat,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  _seccionTitulo(
                    icon: Icons.fact_check_outlined,
                    titulo: "Diagnóstico",
                  ),
                  _datoReporte(
                    "Diagnóstico clínico",
                    consulta['diagnostico'] ?? '---',
                    multiline: true,
                  ),

                  const SizedBox(height: 8),
                  _seccionTitulo(
                    icon: Icons.medication_outlined,
                    titulo: "Medicación recetada",
                  ),
                  const SizedBox(height: 4),

                  if (medicaciones.isEmpty)
                    const Text(
                      "No hay medicaciones registradas.",
                      style: TextStyle(fontSize: 14),
                    )
                  else
                    Column(
                      children:
                          medicaciones.map((m) {
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: azulSuave.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: azulFuerte.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['nombre'] ?? 'Medicamento',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _filaEtiquetaValor(
                                          "Dosis",
                                          m['dosis'] ?? '---',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _filaEtiquetaValor(
                                          "Frecuencia",
                                          m['frecuencia'] ?? '---',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _filaEtiquetaValor(
                                    "Duración",
                                    m['duracion'] ?? '---',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                  const SizedBox(height: 12),
                  const Divider(),
                  _seccionTitulo(
                    icon: Icons.vaccines_outlined,
                    titulo: "Vacunas aplicadas",
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<QuerySnapshot>(
                    stream: vacunasQuery.snapshots(),
                    builder: (context, snapshotVacunas) {
                      if (snapshotVacunas.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }

                      if (!snapshotVacunas.hasData ||
                          snapshotVacunas.data!.docs.isEmpty) {
                        return const Text(
                          "No hay vacunas registradas para esta fecha.",
                          style: TextStyle(fontSize: 14),
                        );
                      }

                      final vacunasDocs = snapshotVacunas.data!.docs;

                      return Column(
                        children:
                            vacunasDocs.map((doc) {
                              final v =
                                  doc.data() as Map<String, dynamic>? ?? {};
                              final nombreVacuna =
                                  v['nombreVacuna'] ?? 'Vacuna';
                              final lote = v['lote'] ?? '---';
                              final dosis = v['dosis'] ?? '---';
                              final aplicador = v['personalAplicador'] ?? '---';

                              DateTime? fechaAplicacion;
                              if (v['fechaAplicacion'] is Timestamp) {
                                fechaAplicacion =
                                    (v['fechaAplicacion'] as Timestamp)
                                        .toDate();
                              }

                              DateTime? fechaProxima;
                              if (v['fechaProxima'] is Timestamp) {
                                fechaProxima =
                                    (v['fechaProxima'] as Timestamp).toDate();
                              }

                              String formatFecha(DateTime? d) {
                                if (d == null) return 'No aplica';
                                return DateFormat('dd/MM/yyyy').format(d);
                              }

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F0FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: azulFuerte.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreVacuna,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _filaEtiquetaValor("Lote", lote),
                                    _filaEtiquetaValor("Dosis", dosis),
                                    _filaEtiquetaValor("Aplicador", aplicador),
                                    _filaEtiquetaValor(
                                      "Fecha aplicación",
                                      formatFecha(fechaAplicacion),
                                    ),
                                    _filaEtiquetaValor(
                                      "Próxima dosis",
                                      formatFecha(fechaProxima),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _seccionTitulo({required IconData icon, required String titulo}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2A74D9)),
          const SizedBox(width: 6),
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _datoReporte(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 245, 245),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              maxLines: multiline ? null : 3,
              overflow:
                  multiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipDetalle({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 246, 252),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A74D9).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2A74D9)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEtiquetaValor(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
