import 'package:flutter/material.dart';
import 'package:login/Pantallas/Login.dart';
import 'package:login/Pantallas/registro.dart';
import 'package:login/Pantallas/veterinario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PETCARE',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      initialRoute: Login.routeName,
      routes: {
        Login.routeName: (_) => const Login(),
        Registro.routeName: (_) => const Registro(),
        Veterinario.routeName: (_) => const Veterinario(),
      },
    );
  }
}
