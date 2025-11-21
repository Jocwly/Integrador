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
    const azulCard = Color(0xFF8FA8FF);
    const textoOscuro = Colors.black;
    const sombra = BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    );

    final size = MediaQuery.of(context).size;
    final cardMinHeight = size.height * 0.16; // altura mínima responsiva
    final imageHeight = size.width * 0.35; // imagen responsiva según ancho

    final clientesRef = FirebaseFirestore.instance.collection('clientes');

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: const SizedBox(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            tooltip: 'Notificaciones',
          ),
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
            itemBuilder:
                (context) => const [
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
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Bienvenido Dr. José!',
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [sombra],
                ),
                clipBehavior: Clip.antiAlias,
                width: double.infinity,
                child: Image.network(
                  'https://www.ladridosybigotes.com/content/images/2024/10/2024-08-13-animal-hoarding-disorder.webp',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              Column(
                children: [
                  // Card CLIENTES
                  StreamBuilder<QuerySnapshot>(
                    stream: clientesRef.snapshots(),
                    builder: (context, snapshot) {
                      String totalClientes = '0';
                      if (snapshot.hasData) {
                        totalClientes = snapshot.data!.docs.length.toString();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Clientes(),
                            ),
                          );
                        },
                        child: _InfoCard(
                          color: azulCard,
                          titulo: 'Clientes',
                          valor: totalClientes,
                          subtitulo: 'Registrados',
                          icono: Icons.groups_rounded,
                          height: cardMinHeight,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Citas hoy
                  _InfoCard(
                    color: azulCard,
                    titulo: 'Citas hoy',
                    valor: '0',
                    subtitulo: '0 completadas',
                    icono: Icons.calendar_today_outlined,
                    height: cardMinHeight,
                  ),
                  const SizedBox(height: 12),

                  // Mascotas
                  _InfoCard(
                    color: azulCard,
                    titulo: 'Mascotas',
                    valor: '0',
                    subtitulo: 'Registradas',
                    icono: Icons.favorite_border,
                    height: cardMinHeight,
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

class _InfoCard extends StatelessWidget {
  final Color color;
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icono;
  final double height; // altura mínima

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
      constraints: BoxConstraints(
        minHeight: height, // ya no es altura fija, puede crecer
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [sombra],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ajuste sutil del tamaño de fuente según la altura disponible
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
