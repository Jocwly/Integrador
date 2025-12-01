import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'citas_channel',
    'Recordatorios de citas',
    description: 'Notificaciones para citas de PETCARE',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> init() async {
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

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
      await androidPlugin.requestNotificationsPermission();
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
        playSound: true,
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

  static Future<void> mostrarNotificacionPrueba() async {
    final details = _notificationDetails();
    await _notificationsPlugin.show(
      999,
      'Prueba de notificación',
      'Si ves esto, las notificaciones locales funcionan ✨',
      details,
    );
  }

  static Future<void> programarNotificacionesCita({
    required int idCita,
    required DateTime fechaHoraCita,
    required String paciente,
    required String duenio,
    required String motivo,
  }) async {
    final details = _notificationDetails();

    final tz.TZDateTime cita = tz.TZDateTime.from(fechaHoraCita, tz.local);
    final tz.TZDateTime unDiaAntes = cita.subtract(const Duration(days: 1));
    final tz.TZDateTime unaHoraAntes = cita.subtract(const Duration(hours: 1));

    final titulo = 'Cita próxima - ${_formatearHora(cita)}';
    final cuerpo = 'Paciente: $paciente.\nDueño: $duenio\nMotivo: $motivo';

    final int baseId = (idCita & 0x7fffffff) % 1000000;
    final int idDiaAntes = baseId * 10 + 1;
    final int idHoraAntes = baseId * 10 + 2;
    final int idHoraExacta = baseId * 10 + 3;

    Future<void> _scheduleIfFuture(
      int id,
      String etiqueta,
      tz.TZDateTime cuando,
    ) async {
      final ahora = tz.TZDateTime.now(tz.local);
      print('[$etiqueta] ahora: $ahora, programada: $cuando (id=$id)');

      if (cuando.isAfter(ahora)) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            titulo,
            cuerpo,
            cuando,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          print('[$etiqueta] ✅ Notificación programada');
        } catch (e) {
          print('[$etiqueta] ❌ ERROR al programar: $e');
        }
      } else {
        print('[$etiqueta] ❌ NO se programa (fecha en el pasado)');
      }
    }

    await _scheduleIfFuture(idDiaAntes, '1 día antes', unDiaAntes);
    await _scheduleIfFuture(idHoraAntes, '1 hora antes', unaHoraAntes);
    await _scheduleIfFuture(idHoraExacta, 'hora exacta', cita);

    final pendientes = await _notificationsPlugin.pendingNotificationRequests();
    print('Pendientes: ${pendientes.length}');
    for (final p in pendientes) {
      print('  - id=${p.id}, title=${p.title}');
    }
  }
}
