import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static int _id = 0;

  /// 🔔 Inicializar notificaciones
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // 🔥 Inicializar zona horaria (OBLIGATORIO)
    tz.initializeTimeZones();
  }

  /// 🔔 Mostrar notificación inmediata
  static Future<void> mostrarNotificacion(String titulo, String cuerpo) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'canal_citas',
          'Citas',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      _id++, // ✅ evita que se sobreescriban
      titulo,
      cuerpo,
      details,
    );
  }

  /// ⏰ Programar notificación (ej: 1 hora antes)
  static Future<void> programarNotificacion(
    String titulo,
    String cuerpo,
    DateTime fecha,
  ) async {
    // 🔴 Evitar programar en el pasado
    if (fecha.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      _id++,
      titulo,
      cuerpo,
      tz.TZDateTime.from(fecha, tz.local), // ✅ CORRECTO
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_citas',
          'Citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
