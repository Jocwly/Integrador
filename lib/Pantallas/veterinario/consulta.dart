import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:login/form_styles.dart';

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

  final List<_MedicationFields> _medicaciones = [_MedicationFields()];

  bool _errMotivo = false;
  bool _errPeso = false;
  bool _errTemp = false;
  bool _errDiag = false;
  bool _errMedNombre = false;
  bool _errMedDosis = false;
  bool _errMedFrecuencia = false;
  bool _errMedDuracion = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _onGuardar() async {
    final firstMed = _medicaciones.first;

    setState(() {
      _errMotivo = _reasonCtrl.text.trim().isEmpty;
      _errPeso = _weightCtrl.text.trim().isEmpty;
      _errTemp = _tempCtrl.text.trim().isEmpty;
      _errDiag = _diagnosisCtrl.text.trim().isEmpty;

      _errMedNombre = firstMed.nombre.text.trim().isEmpty;
      _errMedDosis = firstMed.dosis.text.trim().isEmpty;
      _errMedFrecuencia = firstMed.frecuencia.text.trim().isEmpty;
      _errMedDuracion = firstMed.duracion.text.trim().isEmpty;
    });

    if (_errMotivo ||
        _errPeso ||
        _errTemp ||
        _errDiag ||
        _errMedNombre ||
        _errMedDosis ||
        _errMedFrecuencia ||
        _errMedDuracion)
      return;

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    final meds =
        _medicaciones
            .map(
              (m) => {
                'nombre': m.nombre.text,
                'dosis': m.dosis.text,
                'frecuencia': m.frecuencia.text,
                'duracion': m.duracion.text,
              },
            )
            .toList();

    await mascotaRef.collection('consultas').add({
      'fechaStr': _dateCtrl.text,
      'fecha': DateFormat('dd/MM/yyyy').parse(_dateCtrl.text),
      'motivo': _reasonCtrl.text,
      'peso': _weightCtrl.text,
      'temperatura': _tempCtrl.text,
      'diagnostico': _diagnosisCtrl.text,
      'medicaciones': meds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FormStyles.appBarGradient),
        ),
        centerTitle: true,
        title: const Text(
          'Nueva consulta médica',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: FormStyles.backgroundGradient,
          ),

          child: StreamBuilder<DocumentSnapshot>(
            stream: mascotaRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Mascota';
              final fotoUrl = data['fotoUrl'];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Container(
                  decoration: FormStyles.cardDecoration,
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: FormStyles.avatarBorderDecoration,
                            padding: const EdgeInsets.all(
                              FormStyles.avatarPadding,
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage:
                                  fotoUrl != null
                                      ? NetworkImage(fotoUrl)
                                      : const AssetImage(
                                            'assets/images/icono.png',
                                          )
                                          as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: FormStyles.mascotaNombre),

                              const SizedBox(height: 4),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: FormStyles.pacienteChipDecoration,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.pets, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      "Paciente",
                                      style: FormStyles.pacienteChipText,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      FormStyles.formDivider,

                      /// CAMPOS
                      _campo(
                        'Fecha',
                        _dateCtrl,
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: _pickDate,
                      ),

                      _campo(
                        'Motivo de la consulta',
                        _reasonCtrl,
                        error: _errMotivo,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _campo(
                              'Peso',
                              _weightCtrl,
                              icon: Icons.monitor_weight,
                              suffixText: 'kg',
                              error: _errPeso,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _campo(
                              'Temperatura',
                              _tempCtrl,
                              icon: Icons.thermostat,
                              suffixText: '°C',
                              error: _errTemp,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      _campo(
                        'Diagnóstico',
                        _diagnosisCtrl,
                        maxLines: 3,
                        error: _errDiag,
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Medicación prescrita',
                          style: FormStyles.labelStyle.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildMedicacionesSection(),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: FormStyles.primaryButton,
                              onPressed: _onGuardar,
                              child: const Text('Guardar'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton(
                              style: FormStyles.outlineButton,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool error = false,
    IconData icon = Icons.edit,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FormStyles.labelStyle),

          const SizedBox(height: 6),

          TextField(
            controller: ctrl,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,

            decoration: FormStyles.inputDecoration(
              hint: label,
              icon: icon,
              error: error,
              suffixText: suffixText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicacionesSection() {
    return Column(
      children: [
        for (int i = 0; i < _medicaciones.length; i++) ...[
          _buildMedicacionForm(_medicaciones[i], i),
          const SizedBox(height: 12),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => _medicaciones.add(_MedicationFields()));
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar medicación',
              style: TextStyle(color: Color(0xFF2A74D9)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicacionForm(_MedicationFields med, int index) {
    return Column(
      children: [
        _campo(
          'Nombre medicamento',
          med.nombre,
          icon: Icons.medication,
          error: index == 0 && _errMedNombre,
        ),

        Row(
          children: [
            Expanded(
              child: _campo(
                'Dosis',
                med.dosis,
                icon: Icons.medication_liquid,
                error: index == 0 && _errMedDosis,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _campo(
                'Frecuencia',
                med.frecuencia,
                icon: Icons.timer,
                error: index == 0 && _errMedFrecuencia,
              ),
            ),
          ],
        ),

        _campo(
          'Duración',
          med.duracion,
          icon: Icons.calendar_today,
          error: index == 0 && _errMedDuracion,
        ),

        FormStyles.formDivider,
      ],
    );
  }
}
