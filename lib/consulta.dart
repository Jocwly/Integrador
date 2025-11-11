import 'package:flutter/material.dart';

class ConsultaMedica extends StatefulWidget {
  const ConsultaMedica({super.key});

  @override
  State<ConsultaMedica> createState() => _ConsultaMedicaState();
}

class _ConsultaMedicaState extends State<ConsultaMedica> {
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _tempCtrl = TextEditingController();
  final TextEditingController _diagnosisCtrl = TextEditingController();
  final TextEditingController _medNameCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();
  final TextEditingController _freqCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl.text = _formatDate(now);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _reasonCtrl.dispose();
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    _diagnosisCtrl.dispose();
    _medNameCtrl.dispose();
    _doseCtrl.dispose();
    _freqCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    final softGrey = Colors.grey.shade200;
    final pillGrey = Colors.grey.shade300;
    const labelStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
    const titleStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w900);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Nueva consulta\nmédica', textAlign: TextAlign.center, style: titleStyle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text('Fecha:', style: labelStyle),
                const SizedBox(height: 6),
                _DateField(
                  controller: _dateCtrl,
                  background: pillGrey,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 18),

                const Text('Motivo de la consulta', style: labelStyle),
                const SizedBox(height: 6),
                _OutlinedField(controller: _reasonCtrl, hint: ''),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Peso', style: labelStyle),
                          const SizedBox(height: 6),
                          _IconPillField(
                            controller: _weightCtrl,
                            icon: Icons.monitor_weight_outlined,
                            background: pillGrey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Temperatura', style: labelStyle),
                          const SizedBox(height: 6),
                          _IconPillField(
                            controller: _tempCtrl,
                            icon: Icons.thermostat_outlined,
                            background: pillGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Text('Diagnóstico', style: labelStyle),
                const SizedBox(height: 6),
                _OutlinedField(
                  controller: _diagnosisCtrl,
                  hint: '',
                  maxLines: 3,
                ),

                const SizedBox(height: 18),
                const Text('Medicación prescrita', style: labelStyle),
                const SizedBox(height: 6),
                _PillField(controller: _medNameCtrl, hint: 'Nombre del medicamento', background: pillGrey),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _PillField(controller: _doseCtrl, hint: 'Dosis', background: pillGrey)),
                    const SizedBox(width: 12),
                    Expanded(child: _PillField(controller: _freqCtrl, hint: 'Frecuencia', background: pillGrey)),
                  ],
                ),

                const SizedBox(height: 12),
                _PillField(controller: _durationCtrl, hint: 'Duración', background: pillGrey),

                const SizedBox(height: 24),
                Text('Frame 31', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF231637),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Cancelar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Container(height: 4, width: 140, decoration: BoxDecoration(color: softGrey, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: first,
      lastDate: last,
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _dateCtrl.text = _formatDate(picked));
    }
  }



}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final Color background;
  final VoidCallback onTap;
  const _DateField({required this.controller, required this.background, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.event_note_outlined),
            filled: true,
            fillColor: background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: _pillBorder(background),
            focusedBorder: _pillBorder(background),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _pillBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 0),
      );
}

class _IconPillField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color background;
  const _IconPillField({required this.controller, required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: _pillBorder(background),
        focusedBorder: _pillBorder(background),
      ),
      keyboardType: TextInputType.number,
    );
  }

  OutlineInputBorder _pillBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 0),
      );
}

class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color background;
  const _PillField({required this.controller, required this.hint, required this.background});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: _pillBorder(background),
        focusedBorder: _pillBorder(background),
      ),
    );
  }

  OutlineInputBorder _pillBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 0),
      );
}

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _OutlinedField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5F79FF), width: 1.6), // azulito del mockup
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5F79FF), width: 1.8),
        ),
      ),
    );
  }
}
