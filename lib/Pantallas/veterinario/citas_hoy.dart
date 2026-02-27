import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/Pantallas/veterinario/veterinario.dart';
import 'package:login/Pantallas/veterinario/Clientes.dart';

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
    // sin orderBy -> no necesitas índice compuesto

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
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
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
              child: Column(
                children: [
                  _FechaSeguimientoCard(fecha: inicioHoy),
                  const SizedBox(height: 16),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collectionGroup('citas')
                              .where('fecha', isGreaterThanOrEqualTo: inicioHoy)
                              .where('fecha', isLessThan: finHoy)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print('ERROR FIRESTORE CITAS HOY: ${snapshot.error}');
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Ordenamos por fecha en Flutter
                        final docs =
                            snapshot.data!.docs.toList()..sort((a, b) {
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
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return _CitaNotificacionCard(
                              data: data,
                              citaRef: doc.reference,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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

// ========== CARD FECHA DE SEGUIMIENTO ==========
class _FechaSeguimientoCard extends StatelessWidget {
  final DateTime fecha;

  const _FechaSeguimientoCard({required this.fecha});

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('dd/MM/yyyy', 'es').format(fecha);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha de seguimiento',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              fechaStr, // <- FECHA DE HOY POR DEFECTO
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _CitaNotificacionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final DocumentReference citaRef;

  const _CitaNotificacionCard({required this.data, required this.citaRef});

  @override
  State<_CitaNotificacionCard> createState() => _CitaNotificacionCardState();
}

class _CitaNotificacionCardState extends State<_CitaNotificacionCard> {
  String? nombreMascota;
  String? nombreDueno;

  @override
  void initState() {
    super.initState();
    _cargarNombres();
  }

  Future<void> _cargarNombres() async {
    try {
      final mascotaRef = widget.citaRef.parent.parent;
      if (mascotaRef == null) return;

      final mascotaSnap = await mascotaRef.get();
      final mascotaData = mascotaSnap.data() as Map<String, dynamic>?;
      final nombreMascotaLocal = mascotaData?['nombre'] as String?;

      final clienteRef = mascotaRef.parent.parent;
      String? nombreDuenoLocal;

      if (clienteRef != null) {
        final clienteSnap = await clienteRef.get();
        final clienteData = clienteSnap.data() as Map<String, dynamic>?;
        nombreDuenoLocal = clienteData?['nombre'] as String?;
      }

      if (mounted) {
        setState(() {
          nombreMascota = nombreMascotaLocal;
          nombreDueno = nombreDuenoLocal;
        });
      }
    } catch (e) {
      print('Error cargando nombres de cita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final ts = data['fecha'] as Timestamp?;
    final fecha = ts?.toDate();
    final horaStr =
        fecha != null ? DateFormat('hh:mm a').format(fecha) : '--:--';

    final motivo = data['motivo'] ?? 'Motivo no especificado';

    final pacienteTexto = nombreMascota ?? 'Paciente sin nombre';
    final duenoTexto = nombreDueno ?? 'Sin dueño';

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
                      style: TextStyle(fontSize: 11, color: Colors.black45),
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
                  'Paciente: $pacienteTexto.',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Dueño: $duenoTexto.',
                  style: const TextStyle(fontSize: 13),
                ),
                Text('Motivo: $motivo', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
