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

class _ConsultaMedicaState extends State<ConsultaMedica> {
  final _dateCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _medNameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Consulta guardada')));
    Navigator.pop(context, true);
  }

  Future<void> _onCancelar() async {
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: _softBorder(),
      focusedBorder: _softBorder(),
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
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_circle_left_rounded, color: azulFuerte),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva consulta médica',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A74D9),
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
          final fotoUrl = datos['fotoUrl']; // Si ya la guardas en firestore

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // FOTO + NOMBRE
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: azulFuerte, width: 3),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        fotoUrl != null
                            ? NetworkImage(fotoUrl)
                            : const AssetImage('assets/images/perro.jpg')
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: azulFuerte,
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

                // FORMULARIO
                _campo(
                  'Fecha:',
                  _dateCtrl,
                  icon: Icons.event_note_outlined,
                  onTap: _pickDate,
                ),
                _campo('Motivo de la consulta', _reasonCtrl),
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        'Peso',
                        _weightCtrl,
                        icon: Icons.monitor_weight_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo(
                        'Temperatura',
                        _tempCtrl,
                        icon: Icons.thermostat_outlined,
                      ),
                    ),
                  ],
                ),
                _campo('Diagnóstico', _diagnosisCtrl, maxLines: 3),
                _campo('Nombre del medicamento', _medNameCtrl),
                Row(
                  children: [
                    Expanded(child: _campo('Dosis', _doseCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _campo('Frecuencia', _freqCtrl)),
                  ],
                ),
                _campo('Duración', _durationCtrl),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onGuardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFuerte,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onCancelar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
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

  // Widget reutilizable de campos
  Widget _campo(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    int maxLines = 1,
    VoidCallback? onTap,
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
                decoration: _inputDecoration(hint: label, icon: icon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
