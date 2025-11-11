import 'package:flutter/material.dart';
import 'package:login/Login.dart';
import 'package:login/registro.dart';
import 'package:login/veterinario.dart';
import 'package:login/perfil_mascota.dart';
import 'package:login/programar_citas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PETCARE',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: Login.routeName,
      routes: {
        Login.routeName: (_) => const Login(),
        Registro.routeName: (_) => const Registro(),
        Veterinario.routeName: (_) => const Veterinario(),
      },

      home: /*const MyHomePage(title: 'HOME PAGE'),*/ const PerfilMascota(),
    );
  }
}