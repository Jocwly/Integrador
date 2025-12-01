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

  // Focus para cambio de borde
  final FocusNode _focusFecha = FocusNode();
  final FocusNode _focusHora = FocusNode();
  final FocusNode _focusTipo = FocusNode();
  final FocusNode _focusPersonal = FocusNode();

  // Colores de borde
  final Color _borderNormal = const Color(0xFF2A74D9).withOpacity(0.45);
  final Color _borderFocus = const Color(0xFF4E78FF);

  @override
  void dispose() {
    motivoController.dispose();
    _focusFecha.dispose();
    _focusHora.dispose();
    _focusTipo.dispose();
    _focusPersonal.dispose();
    super.dispose();
  }

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

    // 🔴 Validar que la cita sea en el futuro
    if (fechaCompleta.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha y hora de la cita deben ser posteriores a ahora',
          ),
        ),
      );
      return;
    }
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
// 👉 Programar notificaciones locales
final int idCita = (mascotaRef.id.hashCode & 0x7fffffff);


    // Obtener nombre del cliente (dueño)
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
  const lilaFondo1 = Color(0xFFD7D2FF);
  const lilaFondo2 = Color(0xFFF1EEFF);
  const azulOscuro = Color(0xFF0B1446);
  const azulChipOscuro = Color(0xFF0B1446);

  final mascotaRef = FirebaseFirestore.instance
      .collection('clientes')
      .doc(widget.clienteId)
      .collection('mascotas')
      .doc(widget.mascotaId);

  return Scaffold(
    backgroundColor: lilaFondo1,
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
          Icon(Icons.event_available_rounded, color: Colors.white, size: 20),
          SizedBox(width: 6),
          Text(
            'Programar cita',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lilaFondo1, lilaFondo2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
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

            final dynamic fotoDynamic = data['fotoUrl'] ?? data['foto'];
            final String? fotoUrl =
                fotoDynamic is String && fotoDynamic.isNotEmpty
                    ? fotoDynamic
                    : null;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== CABECERA TIPO CONSULTA MÉDICA =====
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4FF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(26),
                              topRight: Radius.circular(26),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: azulChipOscuro,
                                    width: 3,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 34,
                                  backgroundColor: const Color(0xFFEDEFF3),
                                  backgroundImage:
                                      fotoUrl != null
                                          ? NetworkImage(fotoUrl)
                                          : const AssetImage(
                                                'assets/images/perro.jpg',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.pets_rounded,
                                            size: 14,
                                            color: azulChipOscuro,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Paciente",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: azulChipOscuro,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE4E6F2),
                        ),

                        // ===== CONTENIDO DEL FORMULARIO =====
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 18, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detalles de la cita',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Tipo de cita
                              _buildLabel('Tipo de cita:'),
                              _buildDropdown(
                                value: tipoCita,
                                items: tiposCita,
                                borderColor: _borderNormal,
                                focusNode: _focusTipo,
                                onChanged:
                                    (value) => setState(() => tipoCita = value),
                              ),
                              const SizedBox(height: 18),

                              // Fecha y hora
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
                                              ? DateFormat('dd/MM/yyyy').format(
                                                fechaSeleccionada!,
                                              )
                                              : 'Seleccionar',
                                      onTap: () => _seleccionarFecha(context),
                                      borderColor: _borderNormal,
                                      focusNode: _focusFecha,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildPickerField(
                                      icon: Icons.access_time_rounded,
                                      text:
                                          horaSeleccionada != null
                                              ? horaSeleccionada!.format(
                                                context,
                                              )
                                              : 'Seleccionar',
                                      onTap: () => _seleccionarHora(context),
                                      borderColor: _borderNormal,
                                      focusNode: _focusHora,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Motivo
                              _buildLabel('Motivo/Descripción:'),
                              _buildTextArea(
                                controller: motivoController,
                                borderColor: _borderNormal,
                              ),
                              const SizedBox(height: 18),

                              // Personal
                              _buildLabel('Personal asignado:'),
                              _buildDropdown(
                                value: personal,
                                items: personalDisponible,
                                borderColor: _borderNormal,
                                focusNode: _focusPersonal,
                                onChanged:
                                    (value) => setState(() => personal = value),
                              ),
                              const SizedBox(height: 22),

                              // Botones
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: guardarCita,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: azulOscuro,
                                        minimumSize:
                                            const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        elevation: 3,
                                      ),
                                      child: const Text(
                                        'Programar cita',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        backgroundColor:
                                            Colors.grey.shade200,
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: Colors.black87,
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
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

  // Dropdown con borde que cambia al focus
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color borderColor,
    required FocusNode focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (_) => setState(() {}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focusNode.hasFocus ? _borderFocus : borderColor,
            width: 1.6,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          hint: const Text('Seleccionar'),
          decoration: const InputDecoration(border: InputBorder.none),
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.black87,
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
          onTap: () => focusNode.requestFocus(),
        ),
      ),
    );
  }

  // Campo de fecha/hora con borde que cambia al focus
  Widget _buildPickerField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color borderColor,
    required FocusNode focusNode,
  }) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        onTap();
      },
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (_) => setState(() {}),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus ? _borderFocus : borderColor,
              width: 1.6,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextArea normal (sin efecto de focus especial)
  Widget _buildTextArea({
    required TextEditingController controller,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.3),
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
