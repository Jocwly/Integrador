import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitasMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const CitasMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<CitasMascota> createState() => _CitasMascotaState();
}

class _CitasMascotaState extends State<CitasMascota> {
  int _tabIndex = 0; // 0 = Completadas, 1 = Pendientes

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);
    final azulFuerte = const Color(0xFF0B1446);
    final moradoOscuro = const Color(0xFF1C0936);

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    final citasRef = mascotaRef.collection('citas');

    return Scaffold(
      // mismo fondo base que las demás pantallas
      backgroundColor: const Color(0xFFD7D2FF),

      // ───── APPBAR CON DEGRADADO Y FLECHA ─────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E78FF), Color.fromARGB(255, 26, 36, 90)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Citas Mascota',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          // degradado lila de fondo
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: mascotaRef.snapshots(),
            builder: (context, mascotaSnap) {
              if (mascotaSnap.hasError) {
                return const Center(child: Text('Error al cargar la mascota'));
              }
              if (!mascotaSnap.hasData || !mascotaSnap.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final mData = mascotaSnap.data!.data() as Map<String, dynamic>;
              final nombre = mData['nombre'] ?? 'Mascota';

              final dynamic fotoDynamic = mData['fotoUrl'] ?? mData['foto'];
              final String? fotoUrl =
                  fotoDynamic is String && fotoDynamic.isNotEmpty
                      ? fotoDynamic
                      : null;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    citasRef.orderBy('fecha', descending: false).snapshots(),
                builder: (context, citasSnap) {
                  if (citasSnap.hasError) {
                    return const Center(child: Text('Error al cargar citas'));
                  }
                  if (!citasSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = citasSnap.data!.docs;

                  final completadas =
                      docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return (data['completada'] ?? false) == true;
                      }).toList();

                  final pendientes =
                      docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return (data['completada'] ?? false) == false;
                      }).toList();

                  final listaActual = _tabIndex == 0 ? completadas : pendientes;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // FOTO + NOMBRE
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 110, 95, 207),
                                  width: 3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    fotoUrl != null
                                        ? NetworkImage(fotoUrl)
                                        : const AssetImage(
                                              'assets/images/icono.png',
                                            )
                                            as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 12, 8, 43),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // tarjetas resumen
                            Row(
                              children: [
                                Expanded(
                                  child: _resumenCard(
                                    titulo: 'Completadas',
                                    valor: completadas.length,
                                    azulSuave: azulSuave,
                                    icono: Icons.check_circle_outline,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _resumenCard(
                                    titulo: 'Pendientes',
                                    valor: pendientes.length,
                                    azulSuave: azulSuave,
                                    icono: Icons.schedule,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Tabs
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: moradoOscuro,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => _tabIndex = 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              _tabIndex == 0
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Completadas',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _tabIndex == 0
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => _tabIndex = 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              _tabIndex == 1
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Pendientes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _tabIndex == 1
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // lista desplazable
                            Expanded(
                              child:
                                  listaActual.isEmpty
                                      ? const Center(
                                        child: Text(
                                          'No hay citas en esta categoría.',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                      : ListView.separated(
                                        itemCount: listaActual.length,
                                        separatorBuilder:
                                            (_, __) =>
                                                const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final doc = listaActual[index];
                                          final data =
                                              doc.data()
                                                  as Map<String, dynamic>;
                                          return _citaCard(
                                            data: data,
                                            citaId: doc.id,
                                            citasRef: citasRef,
                                            azulSuave: azulSuave,
                                            azulFuerte: azulFuerte,
                                            completada:
                                                (data['completada'] ?? false) ==
                                                true,
                                          );
                                        },
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
      ),
    );
  }

  // ---------- Widgets auxiliares ----------

  Widget _resumenCard({
    required String titulo,
    required int valor,
    required Color azulSuave,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: azulSuave,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icono, size: 18),
              const SizedBox(width: 4),
              Text(
                valor.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _citaCard({
    required Map<String, dynamic> data,
    required String citaId,
    required CollectionReference citasRef,
    required Color azulSuave,
    required Color azulFuerte,
    required bool completada,
  }) {
    final tipo = data['tipo'] ?? 'Sin tipo';
    final motivo = data['motivo'] ?? '';
    final personal = data['personal'] ?? '';
    final fechaTs = data['fecha'] as Timestamp?;
    final fecha = fechaTs?.toDate();

    final fechaStr =
        fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Sin fecha';
    final horaStr =
        fecha != null ? DateFormat('hh:mm a').format(fecha) : '--:--';

    IconData tipoIcon;
    if (tipo.toString().toLowerCase().contains('estética')) {
      tipoIcon = Icons.cut;
    } else if (tipo.toString().toLowerCase().contains('médica') ||
        tipo.toString().toLowerCase().contains('consulta')) {
      tipoIcon = Icons.medical_information_outlined;
    } else if (tipo.toString().toLowerCase().contains('vacuna')) {
      tipoIcon = Icons.vaccines;
    } else {
      tipoIcon = Icons.pets;
    }

    return Container(
      decoration: BoxDecoration(
        color: azulSuave,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(tipoIcon, size: 18, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              _chip(
                tipo.replaceAll('Cita ', '').replaceAll('Consulta ', '').trim(),
              ),
              const SizedBox(width: 6),
              _chip(
                completada ? 'Completada' : 'Programada',
                colorFondo: Colors.white,
                colorTexto: completada ? Colors.green : Colors.black87,
              ),
              const Spacer(),
              Switch(
                value: completada,
                activeColor: Colors.green,
                onChanged: (value) async {
                  await citasRef.doc(citaId).update({
                    'completada': value,
                    'estado': value ? 'Completada' : 'Programada',
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (motivo.isNotEmpty)
            Text(motivo, style: const TextStyle(fontSize: 13)),
          if (motivo.isNotEmpty) const SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14),
                    const SizedBox(width: 4),
                    Text(fechaStr, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(horaStr, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (personal.toString().isNotEmpty)
                Text(
                  personal,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (!completada)
            Row(
              children: [
                ElevatedButton(
                  onPressed:
                      () => _editarFechaHora(
                        context: context,
                        citasRef: citasRef,
                        citaId: citaId,
                        fechaActual: fecha,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulFuerte,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _cancelarCita(context, citasRef, citaId),
                  // onPressed: () => NotificationService().showTestNotification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _chip(
    String texto, {
    Color colorFondo = Colors.white,
    Color colorTexto = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorTexto,
        ),
      ),
    );
  }

  // ---------- Editar fecha y hora ----------

  Future<void> _editarFechaHora({
    required BuildContext context,
    required CollectionReference citasRef,
    required String citaId,
    required DateTime? fechaActual,
  }) async {
    DateTime fechaTemp = fechaActual ?? DateTime.now();
    TimeOfDay horaTemp = TimeOfDay.fromDateTime(fechaActual ?? DateTime.now());

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar fecha y hora'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(DateFormat('dd/MM/yyyy').format(fechaTemp)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fechaTemp,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      fechaTemp = picked;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time_rounded),
                title: Text(horaTemp.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: horaTemp,
                  );
                  if (picked != null) {
                    setState(() {
                      horaTemp = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaFecha = DateTime(
                  fechaTemp.year,
                  fechaTemp.month,
                  fechaTemp.day,
                  horaTemp.hour,
                  horaTemp.minute,
                );
                await citasRef.doc(citaId).update({'fecha': nuevaFecha});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelarCita(
    BuildContext context,
    CollectionReference citasRef,
    String citaId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cancelar cita'),
            content: const Text(
              '¿Seguro que deseas cancelar esta cita? Se eliminará de la lista.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await citasRef.doc(citaId).delete();
    }
  }
}
