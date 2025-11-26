/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultaMedicaDetalles extends StatefulWidget {
  final String clienteId;
  final String mascotaId;
  final String consultaId;

  const ConsultaMedicaDetalles({
    super.key,
    required this.clienteId,
    required this.mascotaId,
    required this.consultaId,
  });

  @override
  State<ConsultaMedicaDetalles> createState() => _ConsultaMedicaDetallesState();
}

class _ConsultaMedicaDetallesState extends State<ConsultaMedicaDetalles> {
  final _dateCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();

  List<Map<String, dynamic>> medicaciones = [];

  final Color azulSuave = const Color(0xFFD6E1F7);
  final Color azulFuerte = const Color(0xFF2A74D9);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .collection('mascotas')
            .doc(widget.mascotaId)
            .collection('consultas')
            .doc(widget.consultaId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _dateCtrl.text = data['fechaStr'] ?? '';
        _reasonCtrl.text = data['motivo'] ?? '';

        _weightCtrl.text =
            data['peso'] != null && data['peso'].toString().isNotEmpty
                ? "${data['peso']} kg"
                : '';

        _tempCtrl.text =
            data['temperatura'] != null &&
                    data['temperatura'].toString().isNotEmpty
                ? "${data['temperatura']} °C"
                : '';

        _diagnosisCtrl.text = data['diagnostico'] ?? '';

        medicaciones = List<Map<String, dynamic>>.from(
          data['medicaciones'] ?? [],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Detalles de consulta',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
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
              _campo("Fecha", _dateCtrl, readOnly: true),
              _campo("Motivo", _reasonCtrl, readOnly: true),
              Row(
                children: [
                  Expanded(
                    child: _campo(
                      "Peso",
                      _weightCtrl,
                      readOnly: true,
                      icon: Icons.monitor_weight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(
                      "Temperatura",
                      _tempCtrl,
                      readOnly: true,
                      icon: Icons.thermostat,
                    ),
                  ),
                ],
              ),
              _campo(
                "Diagnóstico",
                _diagnosisCtrl,
                readOnly: true,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Text(
                "Medicación recetada",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...medicaciones.map(
                (m) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campo(
                      "Medicamento",
                      TextEditingController(text: m['nombre']),
                      readOnly: true,
                      icon: Icons.medication,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            "Dosis",
                            TextEditingController(text: m['dosis']),
                            readOnly: true,
                            icon: Icons.medication_liquid,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            "Frecuencia",
                            TextEditingController(text: m['frecuencia']),
                            readOnly: true,
                            icon: Icons.timer,
                          ),
                        ),
                      ],
                    ),
                    _campo(
                      "Duración",
                      TextEditingController(text: m['duracion']),
                      readOnly: true,
                      icon: Icons.calendar_today,
                    ),
                    const Divider(
                      height: 16,
                      thickness: 1,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            readOnly: readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(
                255,
                241,
                240,
                240,
              ), //CMABIAR EL COLOR DEL FONDO DE LOS CAMPPOSSS
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              prefixIcon:
                  icon != null
                      ? Icon(icon, color: Colors.black54, size: 20)
                      : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: azulFuerte.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: azulFuerte.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}*/
