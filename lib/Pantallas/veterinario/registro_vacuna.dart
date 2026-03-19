import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/form_styles.dart';

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
  final _nombreVacunaCtrl = TextEditingController();
  final _loteCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _dateAplicCtrl = TextEditingController();
  final _dateProxCtrl = TextEditingController();

  DateTime? _fechaAplicacion;
  DateTime? _fechaProxima;

  String? personalId;
  String? personalNombre;

  bool _errNombre = false;
  bool _errLote = false;
  bool _errDosis = false;
  bool _errPersonal = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _fechaAplicacion = today;
    _dateAplicCtrl.text = DateFormat('dd/MM/yyyy').format(today);
  }

  Future<void> _guardar() async {
    setState(() {
      _errNombre = _nombreVacunaCtrl.text.trim().isEmpty;
      _errLote = _loteCtrl.text.trim().isEmpty;
      _errDosis = _dosisCtrl.text.trim().isEmpty;
      _errPersonal = personalId == null;
    });

    if (_errNombre || _errLote || _errDosis || _errPersonal) return;

    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    await mascotaRef.collection('vacunas').add({
      'nombreVacuna': _nombreVacunaCtrl.text.trim(),
      'lote': _loteCtrl.text.trim(),
      'dosis': _dosisCtrl.text.trim(),
      'personalId': personalId,
      'personalNombre': personalNombre,
      'fechaAplicacion': _fechaAplicacion,
      'fechaProxima': _fechaProxima,
      'fechaRegistro': DateTime.now(),
    });

    Navigator.pop(context);
  }

  Future<void> _pickFechaAplicacion() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _fechaAplicacion ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaAplicacion = picked;
        _dateAplicCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFechaProxima() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaProxima = picked;
        _dateProxCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mascotaRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 229, 231, 233),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FormStyles.appBarGradient),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Registrar Vacuna',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                      'Nombre vacuna',
                      _nombreVacunaCtrl,
                      error: _errNombre,
                      icon: Icons.vaccines,
                    ),

                    _campo(
                      'Fecha aplicación',
                      _dateAplicCtrl,
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: _pickFechaAplicacion,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            'Lote',
                            _loteCtrl,
                            error: _errLote,
                            icon: Icons.qr_code,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            'Dosis',
                            _dosisCtrl,
                            error: _errDosis,
                            icon: Icons.medication,
                          ),
                        ),
                      ],
                    ),

                    _campoWidget(
                      "Personal aplicador",
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('personal')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final personalDocs = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            decoration: FormStyles.inputDecoration(
                              hint: 'Seleccionar personal',
                              icon: Icons.person,
                            ).copyWith(
                              errorText:
                                  _errPersonal ? "Selecciona personal" : null,
                            ),
                            value: personalId,
                            items:
                                personalDocs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final nombre = data['nombre'] ?? '';
                                  final rol = data['rol'] ?? '';

                                  final nombreMostrar =
                                      rol == "Veterinario"
                                          ? "MVZ $nombre"
                                          : nombre;

                                  return DropdownMenuItem(
                                    value: doc.id,
                                    child: Text(nombreMostrar),
                                  );
                                }).toList(),
                            onChanged: (v) {
                              final doc = personalDocs.firstWhere(
                                (d) => d.id == v,
                              );
                              final data = doc.data() as Map<String, dynamic>;

                              final nombre = data['nombre'] ?? '';
                              final rol = data['rol'] ?? '';

                              final nombreMostrar =
                                  rol == "Veterinario" ? "MVZ $nombre" : nombre;

                              setState(() {
                                personalId = v;
                                personalNombre = nombreMostrar;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    _campo(
                      'Próxima dosis',
                      _dateProxCtrl,
                      icon: Icons.event,
                      readOnly: true,
                      onTap: _pickFechaProxima,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: FormStyles.primaryButton,
                            onPressed: _guardar,
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
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool error = false,
    IconData icon = Icons.edit,
    bool readOnly = false,
    VoidCallback? onTap,
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
            decoration: FormStyles.inputDecoration(
              hint: label,
              icon: icon,
              error: error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoWidget(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FormStyles.labelStyle),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
