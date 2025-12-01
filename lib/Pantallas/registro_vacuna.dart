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

  bool _errNombre = false;
  bool _errLote = false;
  bool _errDosis = false;
  bool _errPersonal = false;

  // Colores base
  final Color azulSuave = const Color(0xFFD6E1F7);
  final Color azulBordeBase = const Color(0xFF2A74D9);
  final Color botonAzulOscuro = const Color(0xFF0B1446);
  final Color botonGris = const Color(0xFF9FA2B4);

  // Borde normal / focus como en registro / programar cita
  late final Color _borderNormal = azulBordeBase.withOpacity(
    0.45,
  ); // azul clarito
  final Color _borderFocus = const Color(0xFF4E78FF); // azul más oscuro

  final List<String> _personalOpciones = const [
    'Dr. Edson SanJuan',
    'Dra. Abril Peña',
    'Adriana Mendoza',
    'Sharlyn Zenaido',
  ];

  // FocusNodes para efecto de borde
  final FocusNode _focusNombre = FocusNode();
  final FocusNode _focusLote = FocusNode();
  final FocusNode _focusDosis = FocusNode();
  final FocusNode _focusPersonal = FocusNode();
  final FocusNode _focusFechaAplic = FocusNode();
  final FocusNode _focusFechaProx = FocusNode();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _fechaAplicacion = DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    _nombreVacunaCtrl.dispose();
    _loteCtrl.dispose();
    _dosisCtrl.dispose();
    _personalCtrl.dispose();
    _focusNombre.dispose();
    _focusLote.dispose();
    _focusDosis.dispose();
    _focusPersonal.dispose();
    _focusFechaAplic.dispose();
    _focusFechaProx.dispose();
    super.dispose();
  }

  Future<void> _pickFechaAplicacion() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _fechaAplicacion ?? DateTime.now(),
    );
    if (picked != null) {
      setState(
        () =>
            _fechaAplicacion = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _pickFechaProxima() async {
    final today = DateTime.now();
    final baseToday = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      firstDate: baseToday,
      lastDate: DateTime(2100),
      initialDate: baseToday,
      selectableDayPredicate: (day) {
        final onlyDate = DateTime(day.year, day.month, day.day);
        if (onlyDate.isBefore(baseToday)) return false;
        if (day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday) {
          return false;
        }
        return true;
      },
    );

    if (picked != null) {
      setState(
        () => _fechaProxima = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  String _format(DateTime? d) {
    if (d == null) return 'Seleccionar';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  Future<void> _guardar() async {
    setState(() {
      _errNombre = _nombreVacunaCtrl.text.trim().isEmpty;
      _errLote = _loteCtrl.text.trim().isEmpty;
      _errDosis = _dosisCtrl.text.trim().isEmpty;
      _errPersonal = _personalCtrl.text.trim().isEmpty;
    });

    if (_errNombre || _errLote || _errDosis || _errPersonal) return;

    if (_fechaAplicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona la fecha de aplicación")),
      );
      return;
    }

    try {
      final mascotaRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('mascotas')
          .doc(widget.mascotaId);

      await mascotaRef.collection('vacunas').add({
        'nombreVacuna': _nombreVacunaCtrl.text.trim(),
        'lote': _loteCtrl.text.trim(),
        'dosis': _dosisCtrl.text.trim(),
        'personalAplicador': _personalCtrl.text.trim(),
        'fechaAplicacion': _fechaAplicacion,
        'fechaProxima': _fechaProxima,
        'fechaRegistro': DateTime.now(),
      });

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
                "Próxima dosis: "
                "${_fechaProxima == null ? 'No aplica' : _format(_fechaProxima)}",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ],
            ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }
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
  const lilaFondo1 = Color(0xFFD7D2FF);
  const lilaFondo2 = Color(0xFFF1EEFF);
  const azulChipOscuro = Color(0xFF0B1446);

  final mascotaRef = FirebaseFirestore.instance
      .collection('clientes')
      .doc(widget.clienteId)
      .collection('mascotas')
      .doc(widget.mascotaId);

  return Scaffold(
    backgroundColor: lilaFondo1,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.vaccines_rounded, color: Colors.white, size: 20),
          SizedBox(width: 6),
          Text(
            "Registrar vacuna",
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
      child: Container
        (
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lilaFondo1, lilaFondo2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: mascotaRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error al cargar los datos"));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Mascota';

            final dynamic fotoDynamic = data['fotoUrl'] ?? data['foto'];
            final String? fotoUrl =
                fotoDynamic is String && fotoDynamic.isNotEmpty
                    ? fotoDynamic
                    : null;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ====== CABECERA TIPO CONSULTA MÉDICA ======
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4FF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(26),
                              topRight: Radius.circular(26),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: azulChipOscuro,
                                    width: 3,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 34,
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.pets_rounded,
                                            size: 14,
                                            color: azulChipOscuro,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Paciente",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: azulChipOscuro,
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
                        ),

                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE4E6F2),
                        ),

                        // ====== CONTENIDO DEL FORMULARIO ======
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                const Text(
                                  'Detalles de la vacuna',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Nombre vacuna
                                _label("Nombre de la vacuna"),
                                const SizedBox(height: 6),
                                _inputText(
                                  controller: _nombreVacunaCtrl,
                                  showError: _errNombre,
                                  focusNode: _focusNombre,
                                  icon: Icons.vaccines_outlined,
                                  onChanged: () {
                                    if (_errNombre &&
                                        _nombreVacunaCtrl.text
                                            .trim()
                                            .isNotEmpty) {
                                      setState(() => _errNombre = false);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Fecha aplicación
                                _label("Fecha de aplicación"),
                                const SizedBox(height: 6),
                                _dateField(
                                  value: _fechaAplicacion,
                                  onTap: _pickFechaAplicacion,
                                  focusNode: _focusFechaAplic,
                                ),
                                const SizedBox(height: 16),

                                // Lote / dosis
                                Row(
                                  children: [
                                    Expanded(
                                      child: _fieldSmall(
                                        label: "Lote",
                                        controller: _loteCtrl,
                                        showError: _errLote,
                                        focusNode: _focusLote,
                                        onChanged: () {
                                          if (_errLote &&
                                              _loteCtrl.text
                                                  .trim()
                                                  .isNotEmpty) {
                                            setState(() => _errLote = false);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _fieldSmall(
                                        label: "Dosis",
                                        controller: _dosisCtrl,
                                        showError: _errDosis,
                                        focusNode: _focusDosis,
                                        onChanged: () {
                                          if (_errDosis &&
                                              _dosisCtrl.text
                                                  .trim()
                                                  .isNotEmpty) {
                                            setState(() => _errDosis = false);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Personal
                                _label("Personal aplicador"),
                                const SizedBox(height: 6),
                                _dropdownPersonalAplicador(),
                                const SizedBox(height: 16),

                                // Próxima dosis
                                _label("Fecha de próxima dosis (si aplica)"),
                                const SizedBox(height: 6),
                                _dateField(
                                  value: _fechaProxima,
                                  onTap: _pickFechaProxima,
                                  focusNode: _focusFechaProx,
                                ),
                                const SizedBox(height: 26),

                                // Botones
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _guardar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: botonAzulOscuro,
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: const Text(
                                          "Guardar",
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
                                        onPressed: _cancelar,
                                        style: OutlinedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          backgroundColor: botonGris,
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: const Text(
                                          "Cancelar",
                                          style: TextStyle(
                                            color: Colors.black,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}


  // ---------- Widgets auxiliares de estilo ----------

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Colors.black87,
    ),
  );

  Widget _inputText({
    required TextEditingController controller,
    required bool showError,
    required FocusNode focusNode,
    required VoidCallback onChanged,
    IconData? icon,
  }) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (_) => setState(() {}),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                showError
                    ? Colors.red
                    : (focusNode.hasFocus ? _borderFocus : _borderNormal),
            width: 1.6,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon:
                      icon != null
                          ? Icon(icon, size: 20, color: Colors.black87)
                          : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            if (showError)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: icon != null ? 40 : 12),
                    child: const Text(
                      "Este campo es requerido",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fieldSmall({
    required String label,
    required TextEditingController controller,
    required bool showError,
    required FocusNode focusNode,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        _inputText(
          controller: controller,
          showError: showError,
          focusNode: focusNode,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dropdownPersonalAplicador() {
    return Focus(
      focusNode: _focusPersonal,
      onFocusChange: (_) => setState(() {}),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _errPersonal
                    ? Colors.red
                    : (_focusPersonal.hasFocus ? _borderFocus : _borderNormal),
            width: 1.6,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _personalCtrl.text.isNotEmpty ? _personalCtrl.text : null,
            hint: const Text(
              "Seleccionar personal",
              style: TextStyle(fontSize: 14),
            ),
            isExpanded: true,
            items:
                _personalOpciones.map((p) {
                  return DropdownMenuItem<String>(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
            onTap: () => _focusPersonal.requestFocus(),
            onChanged: (value) {
              setState(() {
                _personalCtrl.text = value ?? '';
                _errPersonal = false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required DateTime? value,
    required VoidCallback onTap,
    required FocusNode focusNode,
  }) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        onTap();
      },
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (_) => setState(() {}),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus ? _borderFocus : _borderNormal,
              width: 1.6,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.black87,
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
      ),
    );
  }
}
