import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

  final Color azulSuave = const Color(0xFFD6E1F7);
  final Color azulFuerte = const Color(0xFF2A74D9);

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

  @override
  void dispose() {
    _dateCtrl.dispose();
    _reasonCtrl.dispose();
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    _diagnosisCtrl.dispose();
    for (final m in _medicaciones) {
      m.nombre.dispose();
      m.dosis.dispose();
      m.frecuencia.dispose();
      m.duracion.dispose();
    }
    super.dispose();
  }

  OutlineInputBorder _softBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: azulFuerte.withOpacity(0.5), width: 1.5),
  );
  OutlineInputBorder _grayBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: azulFuerte.withOpacity(0.5), width: 1.5),
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

    final hayErrores =
        _errMotivo ||
        _errPeso ||
        _errTemp ||
        _errDiag ||
        _errMedNombre ||
        _errMedDosis ||
        _errMedFrecuencia ||
        _errMedDuracion;

    if (hayErrores) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos requeridos')),
      );
      return;
    }

    try {
      final mascotaRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('mascotas')
          .doc(widget.mascotaId);
      final List<Map<String, String>> meds = [];
      for (final m in _medicaciones) {
        final nombre = m.nombre.text.trim();
        final dosis = m.dosis.text.trim();
        final frecuencia = m.frecuencia.text.trim();
        final duracion = m.duracion.text.trim();

        final tieneAlgo =
            nombre.isNotEmpty ||
            dosis.isNotEmpty ||
            frecuencia.isNotEmpty ||
            duracion.isNotEmpty;

        if (tieneAlgo) {
          meds.add({
            'nombre': nombre,
            'dosis': dosis,
            'frecuencia': frecuencia,
            'duracion': duracion,
          });
        }
      }
      String medicamentoPrincipal = '';
      String dosisPrincipal = '';
      String frecuenciaPrincipal = '';
      String duracionPrincipal = '';

      if (meds.isNotEmpty) {
        medicamentoPrincipal = meds.first['nombre'] ?? '';
        dosisPrincipal = meds.first['dosis'] ?? '';
        frecuenciaPrincipal = meds.first['frecuencia'] ?? '';
        duracionPrincipal = meds.first['duracion'] ?? '';
      }

      await mascotaRef.collection('consultas').add({
        'fechaStr': _dateCtrl.text,
        'fecha': DateFormat('dd/MM/yyyy').parse(_dateCtrl.text),
        'motivo': _reasonCtrl.text,
        'peso': _weightCtrl.text,
        'temperatura': _tempCtrl.text,
        'diagnostico': _diagnosisCtrl.text,
        'medicamento': medicamentoPrincipal,
        'dosis': dosisPrincipal,
        'frecuencia': frecuenciaPrincipal,
        'duracion': duracionPrincipal,
        'medicaciones': meds,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta guardada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onCancelar() async {
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
    bool gray = false,
    bool error = false,
    String? suffixText,
  }) {
    final fillColor = Colors.white;

    final baseBorder = gray ? _grayBorder() : _softBorder();

    final border =
        error
            ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.6),
            )
            : baseBorder;

    return InputDecoration(
      prefixIcon:
          icon != null ? Icon(icon, color: Colors.black54, size: 20) : null,
      hintText: hint,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: border,
      focusedBorder: border,
      border: InputBorder.none,
      suffixText: suffixText, // APARECE KG AUTOMATICAMENT
      suffixStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextFieldWithError({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool gray = false,
    bool showError = false,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
  }) {
    final decoration = _inputDecoration(
      hint: showError ? '' : hint,
      icon: icon,
      gray: gray,
      error: showError,
      suffixText: suffixText,
    );

    final field = TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: decoration,
      style: TextStyle(
        color: showError ? Colors.transparent : Colors.black,
        fontSize: 14,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );

    final double? height = maxLines == 1 ? 52 : null;

    if (!showError) {
      return SizedBox(height: height, child: field);
    }
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          field,
          const Center(
            child: Text(
              'Este campo es requerido',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Nueva consulta médica',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
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
                    radius: 50,
                    backgroundImage:
                        (fotoUrl != null && (fotoUrl as String).isNotEmpty)
                            ? NetworkImage(fotoUrl)
                            : const AssetImage('assets/images/perro.jpg')
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 13, 0, 60),
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
                Container(
                  decoration: BoxDecoration(
                    color: azulSuave,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _campo(
                        'Fecha:',
                        _dateCtrl,
                        icon: Icons.event_outlined,
                        onTap: _pickDate,
                        grayField: true,
                        showError: false,
                      ),
                      _campo(
                        'Motivo de la consulta',
                        _reasonCtrl,
                        showError: _errMotivo,
                        onChanged: (v) {
                          if (_errMotivo && v.trim().isNotEmpty) {
                            setState(() => _errMotivo = false);
                          }
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _campo(
                              'Peso',
                              _weightCtrl,
                              icon: Icons.monitor_weight,
                              grayField: true,
                              showError: _errPeso,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              suffixText:
                                  'kg', //  AQUÍ APARECEN LOS KILOS EN EL CAMPO
                              onChanged: (v) {
                                if (_errPeso && v.trim().isNotEmpty) {
                                  setState(() => _errPeso = false);
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: _campo(
                              'Temperatura',
                              _tempCtrl,
                              icon: Icons.thermostat_sharp,
                              grayField: true,
                              showError: _errTemp,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              suffixText: '°C',
                              onChanged: (v) {
                                if (_errTemp && v.trim().isNotEmpty) {
                                  setState(() => _errTemp = false);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      _campo(
                        'Diagnóstico',
                        _diagnosisCtrl,
                        maxLines: 3,
                        showError: _errDiag,
                        onChanged: (v) {
                          if (_errDiag && v.trim().isNotEmpty) {
                            setState(() => _errDiag = false);
                          }
                        },
                      ),

                      const SizedBox(height: 6),
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

                      _buildMedicacionesSection(),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onGuardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  13,
                                  0,
                                  60,
                                ),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onCancelar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  148,
                                  148,
                                  148,
                                ),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    int maxLines = 1,
    VoidCallback? onTap,
    bool grayField = false,
    bool showError = false,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
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
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              absorbing: onTap != null,
              child: _buildTextFieldWithError(
                controller: ctrl,
                hint: label,
                icon: icon,
                gray: grayField,
                showError: showError,
                maxLines: maxLines,
                onChanged: onChanged,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                suffixText: suffixText,
              ),
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
              setState(() {
                _medicaciones.add(_MedicationFields());
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Agregar medicación'),
          ),
        ),
      ],
    );
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(height: 1.2, color: Colors.grey.shade300),
    );
  }

  Widget _buildMedicacionForm(_MedicationFields med, int index) {
    final bool isFirst = index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldWithError(
          controller: med.nombre,
          hint: 'Nombre del medicamento',
          gray: true,
          icon: Icons.medication,
          showError: isFirst && _errMedNombre,
          onChanged: (v) {
            if (isFirst && _errMedNombre && v.trim().isNotEmpty) {
              setState(() => _errMedNombre = false);
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextFieldWithError(
                controller: med.dosis,
                hint: 'Dosis',
                gray: true,
                icon: Icons.medication_liquid,
                showError: isFirst && _errMedDosis,
                onChanged: (v) {
                  if (isFirst && _errMedDosis && v.trim().isNotEmpty) {
                    setState(() => _errMedDosis = false);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextFieldWithError(
                controller: med.frecuencia,
                hint: 'Frecuencia',
                icon: Icons.timer,
                gray: true,
                showError: isFirst && _errMedFrecuencia,
                onChanged: (v) {
                  if (isFirst && _errMedFrecuencia && v.trim().isNotEmpty) {
                    setState(() => _errMedFrecuencia = false);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextFieldWithError(
          controller: med.duracion,
          hint: 'Duración',
          gray: true,
          icon: Icons.calendar_today,
          showError: isFirst && _errMedDuracion,
          onChanged: (v) {
            if (isFirst && _errMedDuracion && v.trim().isNotEmpty) {
              setState(() => _errMedDuracion = false);
            }
          },
        ),
        _separator(),
      ],
    );
  }
}
