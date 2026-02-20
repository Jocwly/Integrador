import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/servicios/notification_service.dart';
import 'package:login/form_styles.dart';

class ProgramarCita extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const ProgramarCita({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<ProgramarCita> createState() => _ProgramarCitaState();
}

class _ProgramarCitaState extends State<ProgramarCita> {
  final TextEditingController motivoController = TextEditingController();

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  String? tipoCita;
  String? personal;
  String? nombreMascota;

  final List<String> tiposCita = [
    'Cita estética',
    'Consulta médica',
    'Vacunación',
    'Desparasitación',
  ];

  final List<String> personalDisponible = [
    'Dr. Edson SanJuan',
    'Dra. Abril Peña',
    'Adriana Mendoza',
    'Sharlyn Zenaido',
  ];

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (seleccion != null) {
      setState(() => fechaSeleccionada = seleccion);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (seleccion != null) {
      setState(() => horaSeleccionada = seleccion);
    }
  }

  Future<void> guardarCita() async {
    if (fechaSeleccionada == null || horaSeleccionada == null) return;
    if (tipoCita == null) return;
    if (personal == null) return;

    final fechaCompleta = DateTime(
      fechaSeleccionada!.year,
      fechaSeleccionada!.month,
      fechaSeleccionada!.day,
      horaSeleccionada!.hour,
      horaSeleccionada!.minute,
    );

    if (fechaCompleta.isBefore(DateTime.now())) return;

    final mascotaRef =
        FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .collection('mascotas')
            .doc(widget.mascotaId)
            .collection('citas')
            .doc();

    final clienteSnap =
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .get();

    final nombreDuenio =
        (clienteSnap.data()?['nombre'] ?? 'Propietario') as String;

    final nombrePaciente = nombreMascota ?? 'Mascota';

    await mascotaRef.set({
      'tipo': tipoCita,
      'fecha': fechaCompleta,
      'motivo': motivoController.text,
      'personal': personal,
      'creado': Timestamp.now(),
      'completada': false,
      'estado': 'Programada',
      'clienteId': widget.clienteId,
      'mascotaId': widget.mascotaId,
      'nombreDuenio': nombreDuenio,
      'nombreMascota': nombrePaciente,
    });

    await NotificationService().scheduleCitaNotifications(
      fechaCita: fechaCompleta,
      nombreMascota: nombrePaciente,
      tipoCita: tipoCita!,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

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
        title: const Text(
          'Programar cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: FormStyles.backgroundGradient,
          ),

          child: StreamBuilder<DocumentSnapshot>(
            stream: mascotaRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Mascota';

              nombreMascota ??= nombre;

              final fotoUrl = data['fotoUrl'];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Container(
                  decoration: FormStyles.cardDecoration,
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER PACIENTE =====
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage:
                                fotoUrl != null
                                    ? NetworkImage(fotoUrl)
                                    : const AssetImage(
                                          'assets/images/icono.png',
                                        )
                                        as ImageProvider,
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
                                decoration: FormStyles.pacienteChipDecoration,
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

                      // ===== TIPO CITA =====
                      Text("Tipo de cita", style: FormStyles.labelStyle),
                      FormStyles.spaceSmall,

                      DropdownButtonFormField<String>(
                        decoration: FormStyles.inputDecoration(
                          hint: "Seleccionar",
                        ),
                        value: tipoCita,
                        items:
                            tiposCita
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => tipoCita = v),
                      ),

                      FormStyles.spaceMedium,

                      // ===== FECHA =====
                      // ===== FECHA Y HORA =====
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fecha", style: FormStyles.labelStyle),
                                FormStyles.spaceSmall,

                                TextFormField(
                                  readOnly: true,
                                  decoration: FormStyles.inputDecoration(
                                    hint:
                                        fechaSeleccionada != null
                                            ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(fechaSeleccionada!)
                                            : "Seleccionar",
                                    icon: Icons.calendar_today,
                                  ),
                                  onTap: () => _seleccionarFecha(context),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Hora", style: FormStyles.labelStyle),
                                FormStyles.spaceSmall,

                                TextFormField(
                                  readOnly: true,
                                  decoration: FormStyles.inputDecoration(
                                    hint:
                                        horaSeleccionada != null
                                            ? horaSeleccionada!.format(context)
                                            : "Seleccionar",
                                    icon: Icons.access_time,
                                  ),
                                  onTap: () => _seleccionarHora(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      FormStyles.spaceMedium,

                      // ===== MOTIVO =====
                      Text("Motivo", style: FormStyles.labelStyle),
                      FormStyles.spaceSmall,

                      TextField(
                        controller: motivoController,
                        maxLines: 3,
                        decoration: FormStyles.inputDecoration(hint: "Motivo"),
                      ),

                      FormStyles.spaceMedium,

                      // ===== PERSONAL =====
                      Text("Personal asignado", style: FormStyles.labelStyle),
                      FormStyles.spaceSmall,

                      DropdownButtonFormField<String>(
                        decoration: FormStyles.inputDecoration(
                          hint: "Seleccionar",
                          icon: Icons.person,
                        ),
                        value: personal,
                        items:
                            personalDisponible
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => personal = v),
                      ),

                      FormStyles.spaceLarge,

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: FormStyles.primaryButton,
                              onPressed: guardarCita,
                              child: const Text("Programar cita"),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton(
                              style: FormStyles.outlineButton,
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
