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

    // Crear el canal en Android + pedir permiso de notificaciones
    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
      await androidPlugin
          .requestNotificationsPermission(); // 👈 permiso correcto
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

  /// 👉 Notificación inmediata de prueba (opcional)
  static Future<void> mostrarNotificacionPrueba() async {
    final details = _notificationDetails();
    await _notificationsPlugin.show(
      999,
      'Prueba de notificación',
      'Si ves esto, las notificaciones locales funcionan ✨',
      details,
    );
  }

  /// Programa 3 notificaciones: 1 día antes, 1 hora antes y a la hora exacta
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

    // 👉 Aseguramos que el ID base sea un int positivo y pequeño
    final int baseId = (idCita & 0x7fffffff) % 1000000; // máximo 999,999

    // IDs distintos pero seguros (< 2,147,483,647)
    final int idDiaAntes = baseId * 10 + 1;
    final int idHoraAntes = baseId * 10 + 2;
    final int idHoraExacta = baseId * 10 + 3;

    Future<void> _scheduleIfFuture(
      int id,
      String etiqueta,
      tz.TZDateTime fecha,
    ) async {
      final ahora = tz.TZDateTime.now(tz.local);
      print('[$etiqueta] ahora: $ahora, programada: $fecha (id=$id)');

      if (fecha.isAfter(ahora)) {
        print('[$etiqueta] ✅ se programa notificación');
        await _notificationsPlugin.zonedSchedule(
          id,
          titulo,
          cuerpo,
          fecha,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        print('[$etiqueta] ❌ NO se programa, fecha en el pasado');
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
