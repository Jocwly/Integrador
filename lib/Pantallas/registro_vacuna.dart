import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarVacuna extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const RegistrarVacuna({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

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
    if (d == null) return 'Seleccionar';
    return DateFormat('dd/MM/yyyy').format(d);
  }

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
      builder:
          (_) => AlertDialog(
            title: const Text("¡Vacuna registrada! 🎉"),
            content: Text(
              "Vacuna: ${_nombreVacunaCtrl.text}\n"
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
              ),
            ],
          ),
    );
  }

  Future<void> _cancelar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("¿Cancelar registro?"),
            content: const Text(
              "Se perderá la información. ¿Seguro que quieres cancelar?",
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

    if (confirm == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final azulSuave = const Color(0xFFD6E1F7);
    final azulFuerte = const Color(0xFF2A74D9);

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
          "Registrar vacuna",
          style: TextStyle(
            color: Color(0xFF2A74D9),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: mascotaRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar los datos de la mascota"),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = data['nombre'] ?? 'Mascota';
          final foto = data['foto']; // URL si está guardado en Firestore

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 📸 FOTO CIRCULAR DE LA MASCOTA
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: azulFuerte, width: 3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        foto != null
                            ? NetworkImage(foto)
                            : const AssetImage('assets/images/perro.jpg')
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 8),

                // 🐶 NOMBRE DE LA MASCOTA
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

                // 📋 FORMULARIO DE REGISTRO
                Container(
                  decoration: BoxDecoration(
                    color: azulSuave,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Nombre de la vacuna:"),
                        _inputText(_nombreVacunaCtrl),
                        const SizedBox(height: 16),

                        _label("Fecha de aplicación:"),
                        _dateField(_fechaAplicacion, _pickFechaAplicacion),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: _fieldSmall("Lote", _loteCtrl)),
                            const SizedBox(width: 12),
                            Expanded(child: _fieldSmall("Dosis", _dosisCtrl)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _label("Personal Aplicador:"),
                        _inputText(_personalCtrl),
                        const SizedBox(height: 16),

                        _label("Fecha de próxima dosis (si aplica):"),
                        _dateField(_fechaProxima, _pickFechaProxima),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cancelar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _guardar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: azulFuerte,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Guardar",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- UTILS ----------------

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Colors.black87,
    ),
  );

  Widget _inputText(TextEditingController controller) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF2A74D9).withOpacity(0.5),
        width: 1.5,
      ),
    ),
    child: TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator:
          (v) => v == null || v.isEmpty ? "Este campo es requerido" : null,
    ),
  );

  Widget _fieldSmall(String label, TextEditingController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      _inputText(controller),
    ],
  );

  Widget _dateField(DateTime? value, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A74D9).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: Colors.black54,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            value == null ? "Seleccionar" : _format(value),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    ),
  );
}
