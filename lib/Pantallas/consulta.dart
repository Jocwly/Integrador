import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultaMedica extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const ConsultaMedica({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<ConsultaMedica> createState() => _ConsultaMedicaState();
}

// 👉 Controladores para cada bloque de medicación
class _MedicationFields {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController dosis = TextEditingController();
  final TextEditingController frecuencia = TextEditingController();
  final TextEditingController duracion = TextEditingController();
}

class _ConsultaMedicaState extends State<ConsultaMedica> {
  final _dateCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();

  // Lista dinámica de medicamentos
  final List<_MedicationFields> _medicaciones = [_MedicationFields()];

  final azulSuave = const Color(0xFFD6E1F7);
  final azulFuerte = const Color(0xFF2A74D9);

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  OutlineInputBorder _softBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: azulFuerte.withOpacity(0.4), width: 1.2),
      );

  OutlineInputBorder _grayBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.transparent, width: 0),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _onGuardar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consulta guardada')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _onCancelar() async {
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
    bool gray = false,
  }) {
    final fillColor = gray ? const Color(0xFFE6E6E6) : Colors.white;
    final border = gray ? _grayBorder() : _softBorder();

    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      hintText: hint,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: border,
      focusedBorder: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_circle_left_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva consulta médica',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
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

          final datos = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = datos['nombre'] ?? 'Mascota';
          final fotoUrl = datos['fotoUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 👇 FOTO Y NOMBRE – NO LOS TOCO, SOLO COLORES
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 13, 0, 60),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: fotoUrl != null
                        ? NetworkImage(fotoUrl)
                        : const AssetImage('assets/images/perro.jpg')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 13, 0, 60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

                // 👉 Fecha (pill gris)
                _campo(
                  'Fecha:',
                  _dateCtrl,
                  icon: Icons.event_outlined,
                  onTap: _pickDate,
                  grayField: true,
                ),

                // 👉 Motivo, borde azul
                _campo('Motivo de la consulta', _reasonCtrl),

                // Peso / Temperatura con pill gris
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        'Peso',
                        _weightCtrl,
                        icon: Icons.monitor_weight,
                        grayField: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo(
                        'Temperatura',
                        _tempCtrl,
                        icon: Icons.thermostat_sharp,
                        grayField: true,
                      ),
                    ),
                  ],
                ),

                // Diagnóstico borde azul
                _campo('Diagnóstico', _diagnosisCtrl, maxLines: 3),

                const SizedBox(height: 6),
                // Título "Medicación prescrita"
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Medicación prescrita',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 👉 Sección dinámica de medicación
                _buildMedicacionesSection(),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onGuardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 13, 0, 60),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onCancelar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 148, 148, 148),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
          );
        },
      ),
    );
  }

  // --------- CAMPOS GENERALES (motivo, peso, etc.) ---------

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    int maxLines = 1,
    VoidCallback? onTap,
    bool grayField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              absorbing: onTap != null,
              child: TextField(
                controller: ctrl,
                maxLines: maxLines,
                decoration: _inputDecoration(
                  hint: label,
                  icon: icon,
                  gray: grayField,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------- SECCIÓN DE MEDICACIÓN DINÁMICA ---------

  Widget _buildMedicacionesSection() {
    return Column(
      children: [
        for (int i = 0; i < _medicaciones.length; i++) ...[
          _buildMedicacionForm(_medicaciones[i]),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _medicaciones.add(_MedicationFields());
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar medicación'),
          ),
        ),
      ],
    );
  }
  Widget _separator() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      height: 1.2,
      color: Colors.grey.shade300,
    ),
  );
}


  Widget _buildMedicacionForm(_MedicationFields med) {
    return Column(
      children: [
        // Nombre del medicamento (pill gris grande)
        TextField(
          controller: med.nombre,
          decoration: _inputDecoration(
            hint: 'Nombre del medicamento',
            gray: true,
          ),
        ),
        const SizedBox(height: 10),
        // Dosis / Frecuencia
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: med.dosis,
                decoration: _inputDecoration(
                  hint: 'Dosis',
                  gray: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: med.frecuencia,
                decoration: _inputDecoration(
                  hint: 'Frecuencia',
                  gray: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Duración
        TextField(
          controller: med.duracion,
          decoration: _inputDecoration(
            hint: 'Duración',
            gray: true,
          ),
        ),
        _separator()
      ],
    );
  }
}
