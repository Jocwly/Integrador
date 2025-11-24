import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/Clientes.dart';
import 'package:login/main.dart';

class Veterinario extends StatelessWidget {
  static String routeName = '/veterinario';

  const Veterinario({super.key});

  @override
  Widget build(BuildContext context) {
    const fondo = Color(0xFFE6E6E6);
    const azulCardClaro = Color(0xFF8FA8FF);
    const azulCardOscuro = Color(0xFF2965C7);
    const textoOscuro = Colors.black;
    const sombra = BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    );

    final size = MediaQuery.of(context).size;
    final cardMinHeight = size.height * 0.16;
    final imageHeight = size.width * 0.35;

    final clientesRef = FirebaseFirestore.instance.collection('clientes');

    // --- para las citas de HOY ---
    final now = DateTime.now();
    final inicioHoy = DateTime(now.year, now.month, now.day);
    final finHoy = inicioHoy.add(const Duration(days: 1));

    final citasHoyQuery = FirebaseFirestore.instance
        .collectionGroup('citas')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoy))
        .where('fecha', isLessThan: Timestamp.fromDate(finHoy));

    // --- para total de mascotas (todas las subcolecciones mascotas) ---
    final mascotasQuery =
        FirebaseFirestore.instance.collectionGroup('mascotas');

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
            tooltip: 'Notificaciones',
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              if (value == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<int>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Dr. José'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Bienvenido Dr. Jose!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textoOscuro,
                ),
              ),
              const SizedBox(height: 10),

              // IMAGEN RESPONSIVA
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [sombra],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://www.ladridosybigotes.com/content/images/2024/10/2024-08-13-animal-hoarding-disorder.webp',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // === CARDS ===
              Column(
                children: [
                  // Fila 1: CLIENTES (card grande, ocupa todo)
                  StreamBuilder<QuerySnapshot>(
                    stream: clientesRef.snapshots(),
                    builder: (context, snapshot) {
                      String totalClientes = '0';
                      if (snapshot.hasData) {
                        totalClientes =
                            snapshot.data!.docs.length.toString();
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Clientes(),
                                  ),
                                );
                              },
                              child: _InfoCard(
                                color: azulCardClaro,
                                titulo: 'Clientes',
                                valor: totalClientes,
                                subtitulo: 'Registrados',
                                icono: Icons.groups_rounded,
                                height: cardMinHeight,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Fila 2: Citas hoy y Mascotas (dos cards pequeñas en una fila)
                  Row(
                    children: [
                      // --- Citas hoy (contador) ---
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: citasHoyQuery.snapshots(),
                          builder: (context, snapshot) {
                            int totalHoy = 0;
                            int completadasHoy = 0;

                            if (snapshot.hasData) {
                              totalHoy = snapshot.data!.docs.length;
                              for (var d in snapshot.data!.docs) {
                                final data =
                                    d.data() as Map<String, dynamic>;
                                if ((data['completada'] ?? false) == true) {
                                  completadasHoy++;
                                }
                              }
                            }

                            return _InfoCard(
                              color: azulCardOscuro,
                              titulo: 'Citas hoy',
                              valor: totalHoy.toString(),
                              subtitulo: '$completadasHoy completadas',
                              icono: Icons.calendar_today_outlined,
                              height: cardMinHeight,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // --- Mascotas (contador total) ---
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: mascotasQuery.snapshots(),
                          builder: (context, snapshot) {
                            int totalMascotas = 0;
                            if (snapshot.hasData) {
                              totalMascotas = snapshot.data!.docs.length;
                            }

                            return _InfoCard(
                              color: azulCardOscuro,
                              titulo: 'Mascotas',
                              valor: totalMascotas.toString(),
                              subtitulo: 'Registradas',
                              icono: Icons.favorite_border,
                              height: cardMinHeight,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NO CAMBIÉ NADA AQUÍ
class _InfoCard extends StatelessWidget {
  final Color color;
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icono;
  final double height;

  const _InfoCard({
    required this.color,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icono,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    const sombra = BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    );

    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [sombra],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxHeight < 120;
          final valueFontSize = isSmall ? 30.0 : 36.0;
          final titleFontSize = isSmall ? 15.0 : 16.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: titleFontSize,
                    ),
                  ),
                  Icon(icono, color: Colors.black, size: 22),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                valor,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: valueFontSize,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}
