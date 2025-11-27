import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Plugin interno que usaremos en toda la app
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'citas_channel', // id único
        'Recordatorios de citas', // nombre visible
        description: 'Notificaciones para citas de PETCARE',
        importance: Importance.max,
        playSound: true,
      );

  /// Llamar UNA VEZ al iniciar la app (en main)
  static Future<void> init() async {
    // Zona horaria (puedes cambiarla si estás en otro país)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Crear el canal en Android
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
               AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null){           
     await androidPlugin.createNotificationChannel(_androidChannel);
     await androidPlugin.requestFullScreenIntentPermission();
    }
  }

  static NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true, // sonido por defecto
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );
  }

  static String _formatearHora(tz.TZDateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Programa 3 notificaciones: 1 día antes, 1 hora antes y a la hora exacta
  static Future<void> programarNotificacionesCita({
    required int idCita,
    required DateTime fechaHoraCita,
    required String paciente,
    required String duenio,
    required String motivo,
  }) async {
    final tz.TZDateTime cita = tz.TZDateTime.from(fechaHoraCita, tz.local);

    final tz.TZDateTime unDiaAntes = cita.subtract(const Duration(days: 1));
    final tz.TZDateTime unaHoraAntes = cita.subtract(const Duration(hours: 1));

    final details = _notificationDetails();

    final titulo = 'Cita próxima - ${_formatearHora(cita)}';
    final cuerpo = 'Paciente: $paciente.\nDueño: $duenio\nMotivo: $motivo';

    // IDs distintos para que no se sobreescriban
    final int idDiaAntes = idCita * 10 + 1;
    final int idHoraAntes = idCita * 10 + 2;
    final int idHoraExacta = idCita * 10 + 3;

    Future<void> _scheduleIfFuture(int id, tz.TZDateTime fecha) async {
      if (fecha.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notificationsPlugin.zonedSchedule(
          id,
          titulo,
          cuerpo,
          fecha,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    }

    await _scheduleIfFuture(idDiaAntes, unDiaAntes);
    await _scheduleIfFuture(idHoraAntes, unaHoraAntes);
    await _scheduleIfFuture(idHoraExacta, cita);
  }
  
}

