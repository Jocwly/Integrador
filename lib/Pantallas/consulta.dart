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

  // Colores copiados del perfil de cliente
  final Color azulSuave = const Color(0xFFF4F6FF);
  final Color azulFuerte = const Color(0xFF5F79FF);
  final Color azulOscuro = const Color(0xFF0B1446);

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
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: azulFuerte.withOpacity(0.5), width: 1.3),
  );

  OutlineInputBorder _grayBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: azulFuerte.withOpacity(0.25), width: 1.3),
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
    final fillColor = const Color(0xFFF4F6FF); // mismo fondo que las "pills"
    final baseBorder = gray ? _grayBorder() : _softBorder();

    final border =
        error
            ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.red, width: 1.6),
            )
            : baseBorder;

    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: azulFuerte, size: 20) : null,
      hintText: hint,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border,
      focusedBorder: border,
      border: InputBorder.none,
      suffixText: suffixText,
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

    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width < 360 ? 12 : 16;
    final double cardRadius = size.width < 360 ? 22 : 28;

    return Scaffold(
      // mismo fondo base lila
      backgroundColor: const Color(0xFFD7D2FF),

      // 🔵 APPBAR IGUAL QUE PERFIL DEL CLIENTE
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF67A8FF), Color(0xFF2464EB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              'Nueva consulta médica',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          // mismo degradado del cuerpo
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7D2FF), Color(0xFFF1EEFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: StreamBuilder<DocumentSnapshot>(
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

                  final dynamic fotoDynamic = datos['fotoUrl'] ?? datos['foto'];
                  final String? fotoUrl =
                      fotoDynamic is String && fotoDynamic.isNotEmpty
                          ? fotoDynamic
                          : null;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      24,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado tipo perfil
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: azulFuerte.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: const Color(0xFFEDEFF3),
                                  backgroundImage:
                                      fotoUrl != null
                                          ? NetworkImage(fotoUrl)
                                          : const AssetImage(
                                                'assets/images/perro.jpg',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: Color(0xFF0B1446),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: azulFuerte.withOpacity(.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.pets,
                                            size: 14,
                                            color: Color(0xFF5F79FF),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Paciente PetCare',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: azulFuerte,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),
                          const Divider(height: 1),

                          const SizedBox(height: 18),

                          _campo(
                            'Fecha',
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
                                  suffixText: 'kg',
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
                          const Text(
                            'Medicación prescrita',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),

                          _buildMedicacionesSection(),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _onGuardar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azulOscuro,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    shadowColor: const Color(0x33000000),
                                    elevation: 4,
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
                                child: OutlinedButton(
                                  onPressed: _onCancelar,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
        ),
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
              foregroundColor: azulFuerte,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
