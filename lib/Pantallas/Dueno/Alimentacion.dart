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

  final DateFormat fechaFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
        'Seguimiento de Alimentación',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  // ===================== ADMINISTRAR =====================
  Future<void> administrar(String id) async {
    final hora = DateFormat('hh:mm a').format(DateTime.now());

    await _db
        .collection('mascotas')
        .doc(widget.mascotaId)
        .collection('alimentacion')
        .doc(id)
        .update({'administrado': true, 'horaAdministrado': hora});
  }

  // ===================== FORMULARIO =====================
  void mostrarFormulario() {
    _controller.forward();

    String tipo = 'Desayuno';
    final alimentoCtrl = TextEditingController();
    final cantidadCtrl = TextEditingController();
    TimeOfDay hora = TimeOfDay.now();

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
                        const Text(
                          'Agregar comidas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

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
                            hint: "Ej. Croquetas Premium",
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

                        FormStyles.spaceMedium,

                        const Text('Hora', style: FormStyles.labelStyle),
                        FormStyles.spaceSmall,

                        GestureDetector(
                          onTap: () async {
                            final h = await showTimePicker(
                              context: context,
                              initialTime: hora,
                            );
                            if (h != null) {
                              setModalState(() => hora = h);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: FormStyles.azulSuave,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: FormStyles.azulFuerte.withOpacity(0.5),
                                width: 1.3,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(hora.format(context)),
                                const Icon(Icons.access_time),
                              ],
                            ),
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
                                  await _db
                                      .collection('mascotas')
                                      .doc(widget.mascotaId)
                                      .collection('alimentacion')
                                      .add({
                                        'tipo': tipo,
                                        'alimento': alimentoCtrl.text,
                                        'cantidad': cantidadCtrl.text,
                                        'hora': hora.format(context),
                                        'administrado': false,
                                        'horaAdministrado': '',
                                        'fecha': Timestamp.now(),
                                      });

                                  Navigator.pop(context);
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
        return Transform.scale(scale: anim.value, child: child);
      },
    );
  }

  // ===================== UI PRINCIPAL =====================
  @override
  Widget build(BuildContext context) {
    final fechaHoy = fechaFormat.format(DateTime.now());

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
              // ===== FECHA DE SEGUIMIENTO =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: FormStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fecha de seguimiento",
                      style: FormStyles.labelStyle,
                    ),
                    FormStyles.spaceSmall,
                    Text(
                      fechaHoy,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== BOTÓN AGREGAR =====
              GestureDetector(
                onTap: mostrarFormulario,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: FormStyles.appBarGradient,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  child: const Center(
                    child: Text(
                      "+ Agregar comidas",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final administrado = d['administrado'] ?? false;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    administrado
                                        ? Colors.green.shade50
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d['tipo'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(d['alimento']),
                                        Text("Cantidad: ${d['cantidad']} gr"),
                                        if (administrado)
                                          Text(
                                            "Administrado a las ${d['horaAdministrado']}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: administrado,
                                    onChanged:
                                        administrado
                                            ? null
                                            : (_) => administrar(doc.id),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
