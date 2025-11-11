import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: const SizedBox(), 
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 4),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(""
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.center,
                    child: Text ("UsuarioX", style: TextStyle(color: Colors.black, fontSize: 18),)
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.black
                    ),
                    title: Text(
                      'Clientes',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Clientes())),
                  )
                ],
              )
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Bienvenido Dra. Sharlyn!',
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/Vet.jpg', fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      color: azulCard,
                      titulo: 'Clientes',
                      valor: '0',
                      subtitulo: 'Registrados',
                      icono: Icons.groups_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      color: azulCard,
                      titulo: 'Mascotas',
                      valor: '0',
                      subtitulo: 'Registradas',
                      icono: Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 165, 
                child: _InfoCard(
                  color: azulCard,
                  titulo: 'Citas hoy',
                  valor: '0',
                  subtitulo: '0 completadas',
                  icono: Icons.calendar_today_outlined,
                ),
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
    required this.icono,
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
          // Título e icono a la derecha
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
          // Número grande
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
          // Subtítulo pequeño
          Text(
            subtitulo,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
