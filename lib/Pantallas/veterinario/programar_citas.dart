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
  String? personalNombre;
  String? nombreMascota;
  bool _mostrarErrores = false;

  final List<String> tiposCita = [
    'Cita estética',
    'Consulta médica',
    'Vacunación',
    'Desparasitación',
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
    try {
      setState(() {
        _mostrarErrores = true;
      });

      if (fechaSeleccionada == null ||
          horaSeleccionada == null ||
          tipoCita == null ||
          personal == null ||
          motivoController.text.trim().isEmpty) {
        return;
      }

      final fechaCompleta = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      );

      final mascotaRef =
          FirebaseFirestore.instance
              .collection('clientes')
              .doc(widget.clienteId)
              .collection('mascotas')
              .doc(widget.mascotaId)
              .collection('citas')
              .doc();

      await mascotaRef.set({
        'tipo': tipoCita,
        'fecha': fechaCompleta,
        'motivo': motivoController.text,
        'personalId': personal,
        'personalNombre': personalNombre,
        'creado': Timestamp.now(),
        'completada': false,
        'estado': 'Programada',
        'clienteId': widget.clienteId,
        'mascotaId': widget.mascotaId,
      });

      print("✅ CITA GUARDADA");
      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      print("❌ ERROR AL GUARDAR CITA: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 231, 233),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
              'Programar Cita',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
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

                    Text("Tipo de cita", style: FormStyles.labelStyle),
                    FormStyles.spaceSmall,

                    DropdownButtonFormField<String>(
                      decoration: FormStyles.inputDecoration(
                        hint: "Seleccionar",
                      ).copyWith(
                        errorText:
                            _mostrarErrores && tipoCita == null
                                ? "Campo obligatorio"
                                : null,
                      ),
                      value: tipoCita,
                      items:
                          tiposCita
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => tipoCita = v),
                    ),

                    FormStyles.spaceMedium,
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
                                ).copyWith(
                                  errorText:
                                      _mostrarErrores &&
                                              fechaSeleccionada == null
                                          ? "Selecciona una fecha"
                                          : null,
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
                                ).copyWith(
                                  errorText:
                                      _mostrarErrores &&
                                              horaSeleccionada == null
                                          ? "Selecciona una hora"
                                          : null,
                                ),
                                onTap: () => _seleccionarHora(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    FormStyles.spaceMedium,
                    Text("Motivo", style: FormStyles.labelStyle),
                    FormStyles.spaceSmall,

                    TextField(
                      controller: motivoController,
                      maxLines: 3,
                      decoration: FormStyles.inputDecoration(
                        hint: "Motivo",
                      ).copyWith(
                        errorText:
                            _mostrarErrores &&
                                    motivoController.text.trim().isEmpty
                                ? "Escribe el motivo"
                                : null,
                      ),
                    ),

                    Text("Personal asignado", style: FormStyles.labelStyle),
                    FormStyles.spaceSmall,

                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('personal')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final personalDocs = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          decoration: FormStyles.inputDecoration(
                            hint: "Seleccionar",
                            icon: Icons.person,
                          ).copyWith(
                            errorText:
                                _mostrarErrores && personal == null
                                    ? "Selecciona personal"
                                    : null,
                          ),
                          value: personal,
                          items:
                              personalDocs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                final nombre = data['nombre'] ?? '';
                                final rol = data['rol'] ?? '';

                                final nombreMostrar =
                                    rol == "Veterinario"
                                        ? "MVZ $nombre"
                                        : nombre;

                                return DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(nombreMostrar),
                                );
                              }).toList(),
                          onChanged: (v) {
                            final doc = personalDocs.firstWhere(
                              (d) => d.id == v,
                            );
                            final data = doc.data() as Map<String, dynamic>;

                            final nombre = data['nombre'] ?? '';
                            final rol = data['rol'] ?? '';

                            final nombreMostrar =
                                rol == "Veterinario" ? "MVZ $nombre" : nombre;

                            setState(() {
                              personal = v;
                              personalNombre = nombreMostrar;
                            });
                          },
                        );
                      },
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
        //),
      ),
    );
  }
}
