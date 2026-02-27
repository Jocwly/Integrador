import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/form_styles.dart';

class Alimentacion extends StatefulWidget {
  final String mascotaId;

  const Alimentacion({
    super.key,
    required this.mascotaId,
    required String clienteId,
  });

  @override
  State<Alimentacion> createState() => _AlimentacionState();
}

class _AlimentacionState extends State<Alimentacion>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  DateTime fechaSeleccionada = DateTime.now();
  final DateFormat fechaFormat = DateFormat('dd/MM/yyyy', 'es');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===================== APPBAR =====================
  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: FormStyles.appBarGradient),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Alimentación',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  // ===================== FORMULARIO =====================
  void mostrarFormulario() {
    _controller.reset();
    _controller.forward();

    String tipo = 'Desayuno';
    final alimentoCtrl = TextEditingController();
    final cantidadCtrl = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Center(
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: FormStyles.cardDecoration,
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Agregar comida',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),

                        FormStyles.spaceMedium,

                        const Text(
                          'Tipo de comida',
                          style: FormStyles.labelStyle,
                        ),
                        FormStyles.spaceSmall,

                        DropdownButtonFormField(
                          value: tipo,
                          decoration: FormStyles.inputDecoration(),
                          items:
                              ['Desayuno', 'Comida', 'Cena']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setModalState(() => tipo = v!),
                        ),

                        FormStyles.spaceMedium,

                        const Text(
                          'Tipo de alimento',
                          style: FormStyles.labelStyle,
                        ),
                        FormStyles.spaceSmall,

                        TextField(
                          controller: alimentoCtrl,
                          decoration: FormStyles.inputDecoration(
                            hint: "Ej. Croquetas",
                          ),
                        ),

                        FormStyles.spaceMedium,

                        const Text('Cantidad', style: FormStyles.labelStyle),
                        FormStyles.spaceSmall,

                        TextField(
                          controller: cantidadCtrl,
                          keyboardType: TextInputType.number,
                          decoration: FormStyles.inputDecoration(
                            hint: "Ej. 250",
                            suffixText: "gr",
                          ),
                        ),
                        FormStyles.spaceLarge,

                        // BOTONES
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: FormStyles.outlineButton,
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: FormStyles.primaryButton,
                                onPressed: () async {
                                  final horaActual = DateFormat(
                                    'hh:mm a',
                                  ).format(DateTime.now());

                                  await _db
                                      .collection('mascotas')
                                      .doc(widget.mascotaId)
                                      .collection('alimentacion')
                                      .add({
                                        'tipo': tipo,
                                        'alimento': alimentoCtrl.text,
                                        'cantidad': cantidadCtrl.text,
                                        'administrado':
                                            true, // Automáticamente administrado
                                        'horaAdministrado': horaActual,
                                        'fecha': Timestamp.now(),
                                      });

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$tipo registrado correctamente',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text("Agregar"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(scale: anim, child: child);
      },
    );
  }

  // ===================== SELECCIONAR FECHA =====================
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: FormStyles.azulFuerte,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = picked;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaInicio = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      fechaSeleccionada.day,
    );
    final fechaFin = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      fechaSeleccionada.day,
      23,
      59,
      59,
    );

    return Scaffold(
      appBar: _appBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: FormStyles.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: GestureDetector(
                    onTap: _seleccionarFecha,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: FormStyles.appBarGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: FormStyles.azulFuerte.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Fecha de seguimiento",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fechaFormat.format(fechaSeleccionada),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== BOTÓN AGREGAR =====
              SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: GestureDetector(
                    onTap: mostrarFormulario,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: FormStyles.appBarGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0083B0).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Agregar comida",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== LISTA =====
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _db
                          .collection('mascotas')
                          .doc(widget.mascotaId)
                          .collection('alimentacion')
                          .where(
                            'fecha',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(
                              fechaInicio,
                            ),
                          )
                          .where(
                            'fecha',
                            isLessThanOrEqualTo: Timestamp.fromDate(fechaFin),
                          )
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar los datos',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FormStyles.azulFuerte,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay comidas registradas\npara esta fecha',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final d = doc.data() as Map<String, dynamic>;

                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          builder: (context, double value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.green.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00B4DB),
                                        Color(0xFF0083B0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      d['tipo'].substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['tipo'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        d['alimento'],
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Cantidad: ${d['cantidad']} gr",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          "✓ Administrado a las ${d['horaAdministrado'] ?? d['hora']}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
