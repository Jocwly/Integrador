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

  // flags de error
  bool _errNombre = false;
  bool _errLote = false;
  bool _errDosis = false;
  bool _errPersonal = false;

  // Colores de estilo
  final Color azulSuave = const Color(0xFFD6E1F7);
  final Color azulBorde = const Color(0xFF2A74D9);
  final Color botonAzulOscuro = const Color(0xFF0B1446);
  final Color botonGris = const Color(0xFF9FA2B4);

  @override
  void initState() {
    super.initState();
    // Fecha de aplicación por defecto: HOY
    final today = DateTime.now();
    _fechaAplicacion = DateTime(today.year, today.month, today.day);
  }

  Future<void> _pickFechaAplicacion() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _fechaAplicacion ?? DateTime.now(),
    );
    if (picked != null) {
      final d = DateTime(picked.year, picked.month, picked.day);
      setState(() => _fechaAplicacion = d);
    }
  }

  Future<void> _pickFechaProxima() async {
    final today = DateTime.now();
    final baseToday = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      firstDate: baseToday, // no fechas anteriores
      lastDate: DateTime(2100),
      initialDate: baseToday,
      selectableDayPredicate: (day) {
        final onlyDate = DateTime(day.year, day.month, day.day);
        if (onlyDate.isBefore(baseToday)) return false;
        if (day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday) {
          return false; // no sábados ni domingos
        }
        return true;
      },
    );

    if (picked != null) {
      final d = DateTime(picked.year, picked.month, picked.day);
      setState(() => _fechaProxima = d);
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

    final hayErrores = _errNombre || _errLote || _errDosis || _errPersonal;

    if (hayErrores) return;

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
          "Registrar Vacuna",
          style: TextStyle(
            color: Colors.black,
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
          final foto = data['foto'];

          return LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Foto
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 0, 20, 66),
                              width: 3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                foto != null
                                    ? NetworkImage(foto)
                                    : const AssetImage(
                                          'assets/images/perro.jpg',
                                        )
                                        as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Nombre mascota
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 20, 66),
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
                        const SizedBox(height: 22),

                        // -------- FORMULARIO --------
                        Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: azulSuave,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Nombre de la vacuna"),
                                const SizedBox(height: 6),
                                _inputText(
                                  _nombreVacunaCtrl,
                                  showError: _errNombre,
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

                                _label("Fecha de aplicación"),
                                const SizedBox(height: 6),
                                _dateField(
                                  _fechaAplicacion,
                                  _pickFechaAplicacion,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _fieldSmall(
                                        "Lote",
                                        _loteCtrl,
                                        _errLote,
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
                                        "Dosis",
                                        _dosisCtrl,
                                        _errDosis,
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
                                _label("Personal Aplicador"),
                                const SizedBox(height: 6),
                                _inputText(
                                  _personalCtrl,
                                  showError: _errPersonal,
                                  onChanged: () {
                                    if (_errPersonal &&
                                        _personalCtrl.text.trim().isNotEmpty) {
                                      setState(() => _errPersonal = false);
                                    }
                                  },
                                ),

                                const SizedBox(height: 16),
                                _label("Fecha de próxima dosis (si aplica)"),
                                const SizedBox(height: 6),
                                _dateField(_fechaProxima, _pickFechaProxima),

                                const SizedBox(height: 26),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _guardar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: botonAzulOscuro,
                                          minimumSize: const Size.fromHeight(
                                            52,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
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
                                      child: ElevatedButton(
                                        onPressed: _cancelar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: botonGris,
                                          minimumSize: const Size.fromHeight(
                                            52,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
              );
            },
          );
        },
      ),
    );
  }

  // --------- Widgets de apoyo ---------

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Colors.black87,
    ),
  );

  /// Campo con borde azul + mensaje rojo centrado verticalmente
  Widget _inputText(
    TextEditingController controller, {
    required bool showError,
    IconData? icon,
    required VoidCallback onChanged,
  }) {
    final borderColor = showError ? Colors.red : azulBorde.withOpacity(0.5);
    final leftPadding = icon != null ? 40.0 : 12.0;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.6),
      ),
      child: Stack(
        children: [
          // TextField "normal"
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
          // Mensaje de error
          if (showError)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: leftPadding),
                  child: const Text(
                    "Este campo es requerido",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldSmall(
    String label,
    TextEditingController controller,
    bool showError, {
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        _inputText(controller, showError: showError, onChanged: onChanged),
      ],
    );
  }

  Widget _dateField(DateTime? value, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: azulBorde.withOpacity(0.5), width: 1.6),
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
  );
}
