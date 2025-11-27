import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/servicios/notification_service.dart'; // ajusta la ruta según tu proyecto

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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (seleccion != null) {
      setState(() {
        fechaSeleccionada = seleccion;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? seleccion = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (seleccion != null) {
      setState(() {
        horaSeleccionada = seleccion;
      });
    }
  }

  //  Guardar cita en Firestore
  Future<void> guardarCita() async {
    if (fechaSeleccionada == null || horaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora')));
      return;
    }

    if (tipoCita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el tipo de cita')),
      );
      return;
    }

    if (personal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el personal asignado')),
      );
      return;
    }

    // Referencia al documento de la cita
    final mascotaRef =
        FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .collection('mascotas')
            .doc(widget.mascotaId)
            .collection('citas')
            .doc(); // genera ID automático

    // Fecha y hora completas
    final fechaCompleta = DateTime(
      fechaSeleccionada!.year,
      fechaSeleccionada!.month,
      fechaSeleccionada!.day,
      horaSeleccionada!.hour,
      horaSeleccionada!.minute,
    );

    // Guardar en Firestore
    await mascotaRef.set({
      'tipo': tipoCita,
      'fecha': fechaCompleta,
      'motivo': motivoController.text,
      'personal': personal,
      'creado': Timestamp.now(),
      'completada': false,
      'estado': 'Programada',
    });

    // 👉 Programar notificaciones locales
    // ID único basado en el ID del documento de la cita
    final int idCita = mascotaRef.id.hashCode;

    // Opcional: obtener nombre del cliente (dueño)
    final clienteSnap =
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .get();

    final String nombreDuenio =
        (clienteSnap.data()?['nombre'] ?? 'Propietario') as String;

    await NotificationService.programarNotificacionesCita(
      idCita: idCita,
      fechaHoraCita: fechaCompleta,
      paciente: nombreMascota ?? 'Mascota',
      duenio: nombreDuenio,
      motivo:
          motivoController.text.isNotEmpty
              ? motivoController.text
              : (tipoCita ?? 'Cita veterinaria'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita programada correctamente')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Programar cita',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: mascotaRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = data['nombre'] ?? 'Mascota';
          nombreMascota ??= nombre;

          // 👇 Soporte para fotoUrl (nuevo) y foto (antiguo)
          final dynamic fotoDynamic = data['fotoUrl'] ?? data['foto'];
          final String? fotoUrl =
              fotoDynamic is String && fotoDynamic.isNotEmpty
                  ? fotoDynamic
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // FOTO + NOMBRE
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 20, 66),
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
                            : const AssetImage('assets/images/perro.jpg')
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 13, 0, 60),
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
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: azulSuave,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Tipo de cita:'),
                      _buildDropdown(
                        tipoCita,
                        tiposCita,
                        (value) => setState(() => tipoCita = value),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildLabel('Fecha:')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildLabel('Hora:')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerField(
                              icon: Icons.calendar_today_rounded,
                              text:
                                  fechaSeleccionada != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(fechaSeleccionada!)
                                      : 'Seleccionar',
                              onTap: () => _seleccionarFecha(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPickerField(
                              icon: Icons.access_time_rounded,
                              text:
                                  horaSeleccionada != null
                                      ? horaSeleccionada!.format(context)
                                      : 'Seleccionar',
                              onTap: () => _seleccionarHora(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Motivo/Descripción:'),
                      _buildTextArea(motivoController),
                      const SizedBox(height: 16),

                      _buildLabel('Personal asignado:'),
                      _buildDropdown(
                        personal,
                        personalDisponible,
                        (value) => setState(() => personal = value),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: guardarCita,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  13,
                                  0,
                                  60,
                                ),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Programar cita',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A74D9).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: value, // puede ser null → muestra hint
        hint: const Text('Seleccionar'),
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black87),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPickerField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2A74D9).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2A74D9).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
