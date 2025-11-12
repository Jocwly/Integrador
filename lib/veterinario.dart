import 'package:flutter/material.dart';
import 'package:login/Clientes.dart';
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
                (context) => [
                  const PopupMenuItem<int>(
                    enabled: false,
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Dr. José'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<int>(
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

              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [sombra],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network('https://www.ladridosybigotes.com/content/images/2024/10/2024-08-13-animal-hoarding-disorder.webp'),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 12),

              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Clientes()),
                      );
                    },
                    child: _InfoCard(
                      color: azulCard,
                      titulo: 'Clientes',
                      valor: '0',
                      subtitulo: 'Registrados',
                      icono: Icons.groups_rounded,
                      height: 110, 
                    ),
                  ),
                  const SizedBox(height: 12),

                  _InfoCard(
                    color: azulCard,
                    titulo: 'Citas hoy',
                    valor: '0',
                    subtitulo: '0 completadas',
                    icono: Icons.calendar_today_outlined,
                    height: 110,
                  ),
                  const SizedBox(height: 12),

                  _InfoCard(
                    color: azulCard,
                    titulo: 'Mascotas',
                    valor: '0',
                    subtitulo: 'Registradas',
                    icono: Icons.favorite_border,
                    height: 110,
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

  const _InfoCard({
    required this.color,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icono, required int height,
  });

  @override
  Widget build(BuildContext context) {
    const sombra = BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [sombra],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Icon(icono, color: Colors.black, size: 22),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            valor,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 36,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            subtitulo,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
