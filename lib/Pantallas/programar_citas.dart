import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgramarCita extends StatefulWidget {
  const ProgramarCita({super.key});

  @override
  State<ProgramarCita> createState() => _ProgramarCitaState();
}

class _ProgramarCitaState extends State<ProgramarCita> {
  final TextEditingController motivoController = TextEditingController();
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  String tipoCita = 'Cita estética';
  String personal = 'Jocelyn Angeles';

  final List<String> tiposCita = [
    'Cita estética',
    'Consulta médica',
    'Vacunación',
    'Desparasitación',
  ];

  final List<String> personalDisponible = [
    'Jocelyn Angeles',
    'Dr. Hernández',
    'Martha López',
    'Carlos Ruiz',
  ];

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
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

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);
    final azulFuerte = const Color(0xFF2A74D9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Color(0xFF2A74D9),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Programar cita',
          style: TextStyle(
            color: Color(0xFF2A74D9),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: azulSuave,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tipo de cita:'),
              _buildDropdown(tipoCita, tiposCita, (value) {
                setState(() => tipoCita = value!);
              }),
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
              _buildDropdown(personal, personalDisponible, (value) {
                setState(() => personal = value!);
              }),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cita programada correctamente'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulFuerte,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Programar cita',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Widgets auxiliares limpios

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
    String value,
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
      child: DropdownButtonFormField<String>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black54),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.close_rounded, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
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
