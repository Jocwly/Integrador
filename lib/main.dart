import 'package:flutter/material.dart';
import 'package:login/Pantallas/Login.dart';
import 'package:login/Pantallas/Registrarse.dart';
import 'package:login/Pantallas/veterinario/veterinario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:login/servicios/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 👇 inicializamos las notificaciones locales
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es', 'MX'), // Español México

      supportedLocales: const [Locale('es', 'MX'), Locale('es', 'ES')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
