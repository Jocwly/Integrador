import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/form_styles.dart';

class VisualizarVacunas extends StatelessWidget {
  final String clienteId;
  final String mascotaId;

  const VisualizarVacunas({
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

    final vacunasRef = mascotaRef
        .collection('vacunas')
        .orderBy('fechaAplicacion', descending: true);

    return Scaffold(
      backgroundColor: FormStyles.fondoGradientTop,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FormStyles.appBarGradient),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Vacunas Aplicadas',
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
            gradient: FormStyles.backgroundGradient,
          ),

          child: StreamBuilder<DocumentSnapshot>(
            stream: mascotaRef.snapshots(),
            builder: (context, mascotaSnap) {
              if (!mascotaSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final mascotaData =
                  mascotaSnap.data!.data() as Map<String, dynamic>;

              final nombre = mascotaData['nombre'] ?? 'Mascota';
              final fotoUrl = mascotaData['fotoUrl'];

              return StreamBuilder<QuerySnapshot>(
                stream: vacunasRef.snapshots(),
                builder: (context, vacunasSnap) {
                  if (!vacunasSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = vacunasSnap.data!.docs;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: FormStyles.cardDecoration,
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: FormStyles.avatarBorderDecoration,
                                padding: const EdgeInsets.all(
                                  FormStyles.avatarPadding,
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      fotoUrl != null
                                          ? NetworkImage(fotoUrl)
                                          : const AssetImage(
                                                'assets/images/icono.png',
                                              )
                                              as ImageProvider,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nombre, style: FormStyles.mascotaNombre),

                                  const SizedBox(height: 4),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration:
                                        FormStyles.pacienteChipDecoration,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.pets, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          "Paciente",
                                          style: FormStyles.pacienteChipText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          FormStyles.spaceLarge,

                          if (docs.isEmpty)
                            const Text(
                              "No hay vacunas registradas",
                              style: TextStyle(fontSize: 15),
                            ),

                          ...docs.map((doc) {
                            final v = doc.data() as Map<String, dynamic>;

                            DateTime? fAplicacion =
                                v['fechaAplicacion'] is Timestamp
                                    ? (v['fechaAplicacion'] as Timestamp)
                                        .toDate()
                                    : null;

                            DateTime? fProxima =
                                v['fechaProxima'] is Timestamp
                                    ? (v['fechaProxima'] as Timestamp).toDate()
                                    : null;

                            String format(DateTime? d) =>
                                d == null
                                    ? 'No aplica'
                                    : DateFormat('dd/MM/yyyy').format(d);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE7F0FF),
                                    Color(0xFFD6E6FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(
                                    0xFF2A74D9,
                                  ).withOpacity(0.25),
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.vaccines_rounded,
                                        color: Color(0xFF2A74D9),
                                      ),
                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Text(
                                          v['nombreVacuna'] ?? "Vacuna",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  _chipDato(
                                    Icons.qr_code,
                                    "Lote",
                                    v['lote'] ?? "---",
                                  ),
                                  _chipDato(
                                    Icons.medical_services,
                                    "Dosis",
                                    v['dosis'] ?? "---",
                                  ),
                                  _chipDato(
                                    Icons.person,
                                    "Aplicador",
                                    v['personalAplicador'] ?? "---",
                                  ),
                                  _chipDato(
                                    Icons.calendar_today,
                                    "Aplicación",
                                    format(fAplicacion),
                                  ),
                                  _chipDato(
                                    Icons.event_repeat,
                                    "Próxima dosis",
                                    format(fProxima),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chipDato(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A74D9).withOpacity(0.2)),
      ),

      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2A74D9)),
          const SizedBox(width: 8),

          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
