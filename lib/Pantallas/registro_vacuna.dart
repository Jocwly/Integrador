import 'package:flutter/material.dart';

class RegistrarVacuna extends StatefulWidget {
  const RegistrarVacuna({super.key});

  @override
  State<RegistrarVacuna> createState() => _RegistrarVacunaState();
}

class _RegistrarVacunaState extends State<RegistrarVacuna> {
  final _formKey = GlobalKey<FormState>();

  final _nombreVacunaCtrl = TextEditingController();
  final _loteCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _personalCtrl = TextEditingController();

  DateTime? _fechaAplicacion;
  DateTime? _fechaProxima;

  // --- PICKERS ---
  Future<void> _pickFechaAplicacion() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaAplicacion = picked);
  }

  Future<void> _pickFechaProxima() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaProxima = picked);
  }

  String _format(DateTime? d) {
    if (d == null) return '';
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  // --- GUARDAR ---
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaAplicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona la fecha de aplicación")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¡Vacuna registrada! 🎉"),
        content: Text(
          "La vacuna \"${_nombreVacunaCtrl.text}\" se ha guardado con éxito.\n\n"
          "Lote: ${_loteCtrl.text}\n"
          "Dosis: ${_dosisCtrl.text}\n"
          "Aplicador: ${_personalCtrl.text}\n\n"
          "Aplicación: ${_format(_fechaAplicacion)}\n"
          "Próxima dosis: ${_fechaProxima == null ? 'No aplica' : _format(_fechaProxima)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Vacuna guardada como los dioses! 💉🔥")),
    );
  }

  // --- CANCELAR ---
  Future<void> _cancelar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Cancelar registro?"),
        content: const Text(
          "Si sales ahora se perderá la información.\n"
          "¿Seguro que quieres cancelar?",
        ),
        actions: [
          TextButton(
            child: const Text("Seguir editando"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Sí, cancelar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context); // 👉 REGRESA A LA PANTALLA ANTERIOR
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro cancelado 👌")),
      );
    }
  }

  InputDecoration _input({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _dateField(String title, DateTime? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  value == null ? "Seleccionar fecha" : _format(value),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),  // 👈 REGRESA SIN PEDOS
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text("Registrar", style: TextStyle(color: Colors.black)),
            Text("Vacuna",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreVacunaCtrl,
                decoration: _input(label: "Nombre de la vacuna", icon: Icons.vaccines),
                validator: (v) => (v == null || v.isEmpty)
                    ? "Ingresa el nombre"
                    : null,
              ),
              const SizedBox(height: 16),

              _dateField("Fecha de aplicación", _fechaAplicacion, _pickFechaAplicacion),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _loteCtrl,
                      decoration: _input(label: "Lote"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dosisCtrl,
                      decoration: _input(label: "Dosis"),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _personalCtrl,
                decoration: _input(label: "Personal Aplicador"),
              ),
              const SizedBox(height: 16),

              _dateField("Fecha de próxima dosis (si aplica)", _fechaProxima, _pickFechaProxima),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardar,
                      child: const Text("Guardar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                      ),
                      child: const Text("Cancelar"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
