import 'package:flutter/material.dart';

class ConsultaMedica extends StatefulWidget {
  const ConsultaMedica({super.key});

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
  final _formKey = GlobalKey<FormState>();

  final _pillGrey = Colors.grey.shade300;
  final _softGrey = Colors.grey.shade200;
  static const _label = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
  static const _title = TextStyle(fontSize: 24, fontWeight: FontWeight.w900);

  OutlineInputBorder _pillBorder(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: 0),
      );

  InputDecoration _pillDec({
    String? hint,
    IconData? icon,
    Color? fill,
  }) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: fill ?? _pillGrey,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: _pillBorder(fill ?? _pillGrey),
        focusedBorder: _pillBorder(fill ?? _pillGrey),
      );

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<bool> _confirm(String title, String msg,
      {String ok = 'Aceptar', String cancel = 'Cancelar', Color? okColor}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: okColor),
            child: Text(ok),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = _fmt(DateTime.now());
  }

  @override
  void dispose() {
    for (final c in [
      _dateCtrl,
      _reasonCtrl,
      _weightCtrl,
      _tempCtrl,
      _diagnosisCtrl,
      _medNameCtrl,
      _doseCtrl,
      _freqCtrl,
      _durationCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) setState(() => _dateCtrl.text = _fmt(picked));
  }

  Future<void> _onGuardar() async {
    final ok = await _confirm(
      'Confirmar guardado',
      '¿Deseas guardar la consulta médica?',
      ok: 'Sí, guardar',
      okColor: const Color(0xFF231637),
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta guardada')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _onCancelar() async {
    final ok = await _confirm(
      'Cancelar',
      '¿Deseas cancelar y descartar los cambios?',
      ok: 'Sí, cancelar',
      okColor: Colors.redAccent,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  Widget _textLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: _label),
      );

  Widget _outlinedField(TextEditingController c, {int maxLines = 1}) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF5F79FF), width: 1.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF5F79FF), width: 1.8),
          ),
        ),
      );

  Widget _pillField(TextEditingController c,
          {String? hint, IconData? icon, TextInputType? type}) =>
      TextField(
        controller: c,
        keyboardType: type,
        decoration: _pillDec(hint: hint, icon: icon),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_circle_left, color: Colors.black),
          onPressed: () => Navigator.pop(context), // ← sin confirmación
        ),
        centerTitle: true,
        title: const Text(
          'Nueva consulta\nmédica',
          textAlign: TextAlign.center,
          style: _title,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _textLabel('Fecha:'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateCtrl,
                        readOnly: true,
                        decoration: _pillDec(
                            icon: Icons.event_note_outlined,
                            fill: _pillGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _textLabel('Motivo de la consulta'),
                  _outlinedField(_reasonCtrl),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textLabel('Peso'),
                            _pillField(_weightCtrl,
                                icon: Icons.monitor_weight_outlined,
                                type: TextInputType.number),
                          ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textLabel('Temperatura'),
                            _pillField(_tempCtrl,
                                icon: Icons.thermostat_outlined,
                                type: TextInputType.number),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _textLabel('Diagnóstico'),
                  _outlinedField(_diagnosisCtrl, maxLines: 3),
                  const SizedBox(height: 18),
                  _textLabel('Medicación prescrita'),
                  _pillField(_medNameCtrl,
                      hint: 'Nombre del medicamento'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _pillField(_doseCtrl, hint: 'Dosis')),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _pillField(_freqCtrl, hint: 'Frecuencia')),
                  ]),
                  const SizedBox(height: 12),
                  _pillField(_durationCtrl, hint: 'Duración'),
                  const SizedBox(height: 24),
                  Text('Frame 31',
                      style:
                          TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _onGuardar,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF231637),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Guardar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _onCancelar,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Cancelar',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  Container(
                    height: 4,
                    width: 140,
                    decoration: BoxDecoration(
                        color: _softGrey,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 20),
                ]),
          ),
        ),
      ),
    );
  }
}
