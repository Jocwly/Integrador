import 'package:flutter/material.dart';
import 'package:login/Mascota_vet.dart';
import 'package:login/registrar_mascota.dart';
class Cliente extends StatelessWidget {
  const Cliente({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),

            // Contenido
            Positioned.fill(
              top: 56,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: _CardContenido(theme: theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardContenido extends StatelessWidget {
  const _CardContenido({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFEDEFF3),
              child: Icon(Icons.person, size: 44, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 12),
          // Nombre
          Center(
            child: Text(
              'Adriana X',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Dirección
          Text(
            'Dirección:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _PillInfo(
            icon: Icons.home_filled,
            text: 'Panales, Ixmiquilpan, Hgo.',
          ),
          const SizedBox(height: 16),

          // Teléfono
          Text(
            'Teléfono:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _PillInfo(
            icon: Icons.phone,
            text: '7721345678',
          ),

          const SizedBox(height: 22),

          // Mascotas
          Text(
            'Mascotas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // 🐶 Imagen de la mascota existente
              Expanded(
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(44),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PerfilMascota(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=300',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Firulai',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ➕ Botón Añadir Mascota
              Expanded(
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(44),
                      onTap: () {
                        // 👉 Redirige a otra pantalla
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrarMascota(),
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7FA3FF),
                            width: 4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Añadir\nMascota',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  const _PillInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EBFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
