import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
    // No pedimos permisos especiales aquí, ya vimos que las inmediatas sí llegan.
  }

  NotificationDetails _defaultDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'citas_channel_id',
      'Recordatorios de citas',
      channelDescription: 'Notificaciones para recordatorios de citas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> _scheduleSingleNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    print('[NOTIF] Programando id=$id para: $dateTime (ahora: $now)');

    if (dateTime.isBefore(now)) {
      print('[NOTIF] ❌ No se programa $id porque está en el pasado');
      return;
    }

    await _flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      dateTime,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // sin matchDateTimeComponents porque NO es repetitiva
    );

    print('[NOTIF] ✔ Notificación $id programada correctamente');
  }

  // Notificación inmediata (ya sabes que funciona)
  Future<void> showTestNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      999,
      'Test inmediata',
      'Si ves esto, las notificaciones locales funcionan.',
      _defaultDetails(),
    );
  }

  /// Programa:
  ///  - 1 día antes
  ///  - 1 hora antes
  ///  - A la hora exacta
  Future<void> scheduleCitaNotifications({
    required DateTime fechaCita,
    required String nombreMascota,
    required String tipoCita,
  }) async {
    final ahora = DateTime.now();

    final DateTime unDiaAntes = fechaCita.subtract(const Duration(days: 1));
    final DateTime unaHoraAntes = fechaCita.subtract(const Duration(hours: 1));

    final baseId = fechaCita.millisecondsSinceEpoch ~/ 1000;

    print('========== PROGRAMANDO CITAS ==========');
    print('Cita:        $fechaCita');
    print('1 día antes: $unDiaAntes');
    print('1 hora ant.: $unaHoraAntes');
    print('Ahora:       $ahora');

    // 1 día antes
    if (unDiaAntes.isAfter(ahora)) {
      await _scheduleSingleNotification(
        id: baseId + 1,
        dateTime: unDiaAntes,
        title: 'Recordatorio de cita para $nombreMascota',
        body: 'Mañana tienes una $tipoCita programada para $nombreMascota.',
      );
    } else {
      print('[NOTIF] ❌ 1 día antes ya pasó, no se programa.');
    }

    // 1 hora antes
    if (unaHoraAntes.isAfter(ahora)) {
      await _scheduleSingleNotification(
        id: baseId + 2,
        dateTime: unaHoraAntes,
        title: 'Cita próxima para $nombreMascota',
        body: 'En 1 hora tienes una $tipoCita para $nombreMascota.',
      );
    } else {
      print('[NOTIF] ❌ 1 hora antes ya pasó, no se programa.');
    }

    // Hora exacta
    if (fechaCita.isAfter(ahora)) {
      await _scheduleSingleNotification(
        id: baseId + 3,
        dateTime: fechaCita,
        title: '¡Cita ahora para $nombreMascota!',
        body: 'Es hora de la $tipoCita de $nombreMascota.',
      );
    } else {
      print('[NOTIF] ❌ Hora exacta ya pasó, no se programa.');
    }
  }
}

extension on FlutterLocalNotificationsPlugin {
  schedule(int id, String title, String body, DateTime dateTime, NotificationDetails defaultDetails, {required AndroidScheduleMode androidScheduleMode, required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation}) {}
}
