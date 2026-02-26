import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitasMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;
  final bool soloLectura;

  const CitasMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
    this.soloLectura = false,
  });

  @override
  State<CitasMascota> createState() => _CitasMascotaState();
}

class _CitasMascotaState extends State<CitasMascota> {
  int _tabIndex = 0; // 0 = Completadas, 1 = Pendientes, 2 = Vencidas

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);
    final azulFuerte = const Color(0xFF0B1446);
    final moradoOscuro = const Color(0xFF1C0936);
    final azulFuerted = const Color(0xFF2A74D9);

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    final citasRef = mascotaRef.collection('citas');

    return Scaffold(
      backgroundColor: const Color(0xFFD7D2FF),
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
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot>(
            stream: mascotaRef.snapshots(),
            builder: (context, mascotaSnap) {
              if (!mascotaSnap.hasData || !mascotaSnap.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final mData = mascotaSnap.data!.data() as Map<String, dynamic>;
              final nombre = mData['nombre'] ?? 'Mascota';
              final fotoUrl = (mData['fotoUrl'] ?? mData['foto']) as String?;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    citasRef.orderBy('fecha', descending: false).snapshots(),
                builder: (context, citasSnap) {
                  if (!citasSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = citasSnap.data!.docs;
                  final ahora = DateTime.now();

                  final completadas =
                      docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return (data['completada'] ?? false) == true;
                      }).toList();

                  final pendientes =
                      docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final fecha = (data['fecha'] as Timestamp?)?.toDate();
                        final completada =
                            (data['completada'] ?? false) == true;

                        return !completada &&
                            fecha != null &&
                            fecha.isAfter(ahora);
                      }).toList();

                  final vencidas =
                      docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final fecha = (data['fecha'] as Timestamp?)?.toDate();
                        final completada =
                            (data['completada'] ?? false) == true;

                        return !completada &&
                            fecha != null &&
                            fecha.isBefore(ahora);
                      }).toList();

                  List<QueryDocumentSnapshot> listaActual;

                  if (_tabIndex == 0) {
                    listaActual = completadas;
                  } else if (_tabIndex == 1) {
                    listaActual = pendientes;
                  } else {
                    listaActual = vencidas;
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 16),

                      /// FOTO
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: azulFuerted, width: 3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              fotoUrl != null
                                  ? NetworkImage(fotoUrl)
                                  : const AssetImage('assets/images/icono.png')
                                      as ImageProvider,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// NOMBRE
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 12, 8, 43),
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

                      /// RESUMEN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _resumenCard(
                                titulo: 'Completadas',
                                valor: completadas.length,
                                azulSuave: azulSuave,
                                icono: Icons.check_circle_outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _resumenCard(
                                titulo: 'Pendientes',
                                valor: pendientes.length,
                                azulSuave: azulSuave,
                                icono: Icons.schedule,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _resumenCard(
                                titulo: 'Vencidas',
                                valor: vencidas.length,
                                azulSuave: const Color(0xFFFFE5E5),
                                icono: Icons.warning_amber_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// TABS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: moradoOscuro,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              _buildTab('Completadas', 0),
                              _buildTab('Pendientes', 1),
                              _buildTab('Vencidas', 2),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// LISTA
                      Expanded(
                        child:
                            listaActual.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No hay citas en esta categoría.',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: listaActual.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final doc = listaActual[index];
                                    final data =
                                        doc.data() as Map<String, dynamic>;

                                    return _citaCard(
                                      data: data,
                                      citaId: doc.id,
                                      citasRef: citasRef,
                                      azulSuave: azulSuave,
                                      azulFuerte: azulFuerte,
                                    );
                                  },
                                ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String titulo, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: _tabIndex == index ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _tabIndex == index ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

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
  }) {
    final ahora = DateTime.now();

    final tipo = data['tipo'] ?? 'Sin tipo';
    final motivo = data['motivo'] ?? '';
    final personal = data['personal'] ?? '';
    final completada = (data['completada'] ?? false) == true;

    final fechaTs = data['fecha'] as Timestamp?;
    final fecha = fechaTs?.toDate();

    final esVencida = !completada && fecha != null && fecha.isBefore(ahora);

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
        color: esVencida ? const Color(0xFFFFF2F2) : azulSuave,
        borderRadius: BorderRadius.circular(18),
        border: esVencida ? Border.all(color: Colors.red.shade300) : null,
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
                esVencida
                    ? 'Vencida'
                    : completada
                    ? 'Completada'
                    : 'Programada',
                //colorFondo: Colors.white,
                colorTexto:
                    esVencida
                        ? Colors.red
                        : completada
                        ? Colors.green
                        : Colors.black87,
              ),
              const Spacer(),

              /// SWITCH SOLO SI NO ES VENCIDA
              if (!esVencida)
                Switch(
                  value: completada,
                  activeColor: Colors.green,
                  onChanged:
                      widget.soloLectura
                          ? null // 👈 deshabilitado
                          : (value) async {
                            await citasRef.doc(citaId).update({
                              'completada': value,
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

          /// BOTONES SOLO SI NO ESTÁ COMPLETADA Y NO ES VENCIDA
          if (!widget.soloLectura && !completada && !esVencida)
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await citasRef.doc(citaId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada correctamente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar fecha y hora'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// FECHA
                  ListTile(
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: Text(DateFormat('dd/MM/yyyy').format(fechaTemp)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            fechaTemp.isBefore(DateTime.now())
                                ? DateTime.now()
                                : fechaTemp,
                        firstDate: DateTime.now(), // 🚫 NO PASADAS
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          fechaTemp = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            fechaTemp.hour,
                            fechaTemp.minute,
                          );
                        });
                      }
                    },
                  ),

                  /// HORA
                  ListTile(
                    leading: const Icon(Icons.access_time_rounded),
                    title: Text(horaTemp.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: horaTemp,
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          horaTemp = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
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

                    final ahora = DateTime.now();

                    /// 🚫 VALIDAR FECHA/HORA PASADA
                    if (nuevaFecha.isBefore(ahora)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No puedes seleccionar una fecha u hora pasada',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    /// 🚫 VALIDAR CHOQUE DE HORARIOS
                    final citasMismoDia =
                        await citasRef
                            .where(
                              'fecha',
                              isGreaterThanOrEqualTo: DateTime(
                                nuevaFecha.year,
                                nuevaFecha.month,
                                nuevaFecha.day,
                                0,
                                0,
                              ),
                            )
                            .where(
                              'fecha',
                              isLessThan: DateTime(
                                nuevaFecha.year,
                                nuevaFecha.month,
                                nuevaFecha.day,
                                23,
                                59,
                              ),
                            )
                            .get();

                    bool hayChoque = false;

                    for (var doc in citasMismoDia.docs) {
                      if (doc.id == citaId) continue;

                      final fechaExistente =
                          (doc['fecha'] as Timestamp).toDate();

                      if (fechaExistente.year == nuevaFecha.year &&
                          fechaExistente.month == nuevaFecha.month &&
                          fechaExistente.day == nuevaFecha.day &&
                          fechaExistente.hour == nuevaFecha.hour &&
                          fechaExistente.minute == nuevaFecha.minute) {
                        hayChoque = true;
                        break;
                      }
                    }

                    if (hayChoque) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ya existe una cita en ese horario'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    /// ✅ ACTUALIZAR
                    await citasRef.doc(citaId).update({'fecha': nuevaFecha});

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cita actualizada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _chip(String texto, {Color colorTexto = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
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
}
