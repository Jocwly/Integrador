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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.pets_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Historial médico',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
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
        // ⭐ ANCHOS AJUSTADOS
        final double maxWidth = MediaQuery.of(context).size.width * 0.92;
        final double maxHeight = MediaQuery.of(context).size.height * 0.85;

        return Dialog(
          backgroundColor: Colors.white, // fondo blanco 100%
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: maxWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ HEADER ANCHO Y ELEGANTE
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: azulFuerte,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Reporte de consulta médica",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 26),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    "Fecha de consulta: $fechaFormateada",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade300),

                  // ⭐ DATOS PRINCIPALES
                  _seccionTitulo(
                    icon: Icons.info_outline,
                    titulo: "Datos de la consulta",
                  ),
                  _datoReporte(
                    "Motivo de consulta",
                    consulta['motivo'] ?? '---',
                    multiline: true,
                  ),

                  const SizedBox(height: 8),
                  _seccionTitulo(
                    icon: Icons.monitor_heart_outlined,
                    titulo: "Signos vitales",
                  ),

                  const SizedBox(height: 6),
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
                      const SizedBox(width: 12),
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

                  const SizedBox(height: 12),
                  _seccionTitulo(
                    icon: Icons.fact_check_outlined,
                    titulo: "Diagnóstico",
                  ),
                  _datoReporte(
                    "Diagnóstico clínico",
                    consulta['diagnostico'] ?? '---',
                    multiline: true,
                  ),

                  const SizedBox(height: 12),
                  _seccionTitulo(
                    icon: Icons.medication_outlined,
                    titulo: "Medicación recetada",
                  ),
                  const SizedBox(height: 6),

                  if (medicaciones.isEmpty)
                    const Text(
                      "No hay medicaciones registradas.",
                      style: TextStyle(fontSize: 15),
                    )
                  else
                    Column(
                      children:
                          medicaciones.map((m) {
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: azulSuave.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: azulFuerte.withOpacity(0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['nombre'] ?? 'Medicamento',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _filaEtiquetaValor(
                                    "Dosis",
                                    m['dosis'] ?? "---",
                                  ),
                                  _filaEtiquetaValor(
                                    "Frecuencia",
                                    m['frecuencia'] ?? "---",
                                  ),
                                  _filaEtiquetaValor(
                                    "Duración",
                                    m['duracion'] ?? "---",
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade300),

                  _seccionTitulo(
                    icon: Icons.vaccines_outlined,
                    titulo: "Vacunas aplicadas",
                  ),

                  const SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: vacunasQuery.snapshots(),
                    builder: (context, snapshotVacunas) {
                      if (!snapshotVacunas.hasData) {
                        return const LinearProgressIndicator();
                      }

                      if (snapshotVacunas.data!.docs.isEmpty) {
                        return const Text(
                          "No hay vacunas registradas para esta fecha.",
                          style: TextStyle(fontSize: 14),
                        );
                      }

                      return Column(
                        children:
                            snapshotVacunas.data!.docs.map((doc) {
                              final v = doc.data() as Map<String, dynamic>;

                              DateTime? fAplicacion =
                                  v['fechaAplicacion'] is Timestamp
                                      ? (v['fechaAplicacion'] as Timestamp)
                                          .toDate()
                                      : null;

                              DateTime? fProxima =
                                  v['fechaProxima'] is Timestamp
                                      ? (v['fechaProxima'] as Timestamp)
                                          .toDate()
                                      : null;

                              String format(DateTime? d) =>
                                  d == null
                                      ? 'No aplica'
                                      : DateFormat('dd/MM/yyyy').format(d);

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F0FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: azulFuerte.withOpacity(0.25),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v['nombreVacuna'] ?? "Vacuna",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _filaEtiquetaValor(
                                      "Lote",
                                      v['lote'] ?? "---",
                                    ),
                                    _filaEtiquetaValor(
                                      "Dosis",
                                      v['dosis'] ?? "---",
                                    ),
                                    _filaEtiquetaValor(
                                      "Aplicador",
                                      v['personalAplicador'] ?? "---",
                                    ),
                                    _filaEtiquetaValor(
                                      "Fecha aplicación",
                                      format(fAplicacion),
                                    ),
                                    _filaEtiquetaValor(
                                      "Próxima dosis",
                                      format(fProxima),
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
