import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/Pantallas/Clientes.dart';
import 'package:login/Pantallas/citas_hoy.dart';
import 'package:login/main.dart';

class Veterinario extends StatelessWidget {
  static String routeName = '/veterinario';

  const Veterinario({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores base
    const fondo = Color(0xFFF5F7FB);
    const azulClaro = Color(0xFF8FA8FF);
    const azulOscuro = Color(0xFF2965C7);

    final size = MediaQuery.of(context).size;
    final cardMinHeight = size.height * 0.18;

    final clientesRef = FirebaseFirestore.instance.collection('clientes');

    final now = DateTime.now();
    final inicioHoy = DateTime(now.year, now.month, now.day);
    final finHoy = inicioHoy.add(const Duration(days: 1));

    final citasHoyQuery = FirebaseFirestore.instance
        .collectionGroup('citas')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoy))
        .where('fecha', isLessThan: Timestamp.fromDate(finHoy));

    final mascotasQuery = FirebaseFirestore.instance.collectionGroup(
      'mascotas',
    );

    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
            ),
          ),
        ),
        title: Row(
          children: [
            PopupMenuButton<int>(
              tooltip: 'Menú del doctor',
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
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                child: Icon(Icons.person_outline_outlined, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PetCare',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              tooltip: 'Notificaciones',
            ),
          ],
        ),
      ),

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4E78FF), Color(0xFF0B1446)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _SquareIcon(
                              icon: Icons.person,
                              color: Color.fromARGB(47, 255, 254, 254),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '¡Bienvenido, Dr.!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            // Text(
                            //   'martes, 25 nov',
                            // style: TextStyle(
                            //color: Color(0xFFCBDDFF),
                            // fontSize: 15,
                            // ),
                            //),
                            SizedBox(height: 6),
                            Text(
                              '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          width:
                              size.width *
                              0.40, // ancho fijo para parecerse al mockup
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmuJh-ioHIdZI15Qna5kPbjnsir2qasTnHA&s',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --------- PANEL DE ESTADÍSTICAS ---------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: fondo),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: clientesRef.snapshots(),
                              builder: (context, snapshot) {
                                String totalClientes = '0';
                                if (snapshot.hasData) {
                                  totalClientes =
                                      snapshot.data!.docs.length.toString();
                                }

                                return _InfoCard(
                                  titulo: 'Total Clientes',
                                  valor: totalClientes,
                                  subtitulo: 'Registrados',
                                  icono: Icons.groups_rounded,
                                  height: cardMinHeight,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: mascotasQuery.snapshots(),
                              builder: (context, snapshot) {
                                int totalMascotas = 0;
                                if (snapshot.hasData) {
                                  totalMascotas = snapshot.data!.docs.length;
                                }

                                return _InfoCard(
                                  titulo: 'Total Mascotas',
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
                      const SizedBox(height: 16),

                      Row(
                        children: [
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
                                  titulo: 'Citas de Hoy',
                                  valor: totalHoy.toString(),
                                  subtitulo: '$completadasHoy completadas',
                                  icono: Icons.calendar_today_outlined,
                                  height: cardMinHeight,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // =================== MENÚ INFERIOR ===================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: azulOscuro,
          unselectedItemColor: azulClaro.withOpacity(0.7),
          showUnselectedLabels: true,
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) return;
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Clientes()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CitasHoy()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Citas',
            ),
          ],
        ),
      ),
    );
  }
}

// ============= ICONO CUADRADO AZUL DEL HEADER =============
class _SquareIcon extends StatelessWidget {
  final IconData icon;

  const _SquareIcon({required this.icon, required Color color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B9DFF), Color(0xFF244BCC)],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

// ============= CARD CON EL DEGRADADO IGUAL AL MOCKUP =============
class _InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icono;
  final double height;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icono,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFEFF4FF), Color(0xFFFFFFFF)],
        ),
        border: Border.all(color: Color(0xFFE1E6F2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B9DFF), Color(0xFF244BCC)],
              ),
            ),
            child: Icon(icono, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF7C93FF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(
              color: Color(0xFF050712),
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: Color(0xFF7C93FF)),
              const SizedBox(width: 6),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: Color(0xFF7C93FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
