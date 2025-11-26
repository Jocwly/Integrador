import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:login/Pantallas/veterinario.dart';
import 'package:login/Pantallas/Clientes.dart';

const fondo = Color(0xFFF5F7FB);
const azulClaro = Color(0xFF8FA8FF);
const azulOscuro = Color(0xFF2965C7);

class CitasHoy extends StatelessWidget {
  const CitasHoy({super.key});

  @override
  Widget build(BuildContext context) {
    // Rango de HOY
    final now = DateTime.now();
    final inicioHoy = DateTime(now.year, now.month, now.day);
    final finHoy = inicioHoy.add(const Duration(days: 1));

    final Query citasHoyQuery = FirebaseFirestore.instance
        .collectionGroup('citas')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoy))
        .where('fecha', isLessThan: Timestamp.fromDate(finHoy));
        // OJO: sin orderBy para evitar índice obligatorio

    return Scaffold(
      backgroundColor: fondo,

      // APPBAR
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
              colors: [Color(0xFF71B3FF), Color(0xFF2E63D8)],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Citas de Hoy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // CUERPO
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: citasHoyQuery.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar las citas.'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Ordenamos por fecha en Flutter
                  final docs = snapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final fa =
                          (a['fecha'] as Timestamp?)?.toDate() ??
                          DateTime(2100);
                      final fb =
                          (b['fecha'] as Timestamp?)?.toDate() ??
                          DateTime(2100);
                      return fa.compareTo(fb);
                    });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay citas programadas para hoy.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      return _CitaNotificacionCard(data: data);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),

      // MENÚ INFERIOR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: azulOscuro,
          unselectedItemColor: azulClaro.withOpacity(0.7),
          showUnselectedLabels: true,
          currentIndex: 2,
          onTap: (index) {
            if (index == 2) return;
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Veterinario()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Clientes()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Citas',
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CARD ESTILO NOTIFICACIÓN ==========
class _CitaNotificacionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CitaNotificacionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final ts = data['fecha'] as Timestamp?;
    final fecha = ts?.toDate();

    final horaStr =
        fecha != null ? DateFormat('hh:mm a').format(fecha) : '--:--';

    // SOLO USAMOS CAMPOS QUE SÍ EXISTEN EN TUS CITAS
    final tipo = data['tipo'] ?? 'Cita';
    final motivo = data['motivo'] ?? 'Motivo no especificado';
    final personal = data['personal'] ?? 'Sin asignar';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF265DFF), Color(0xFF001247)],
              ),
            ),
            child: const Icon(Icons.pets, color: Colors.white),
          ),
          const SizedBox(width: 10),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'PETCARE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cita próxima - $horaStr',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipo: $tipo',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Personal: $personal',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Motivo: $motivo',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
