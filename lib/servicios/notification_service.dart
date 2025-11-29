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

  /// Llamar EN main() una sola vez
  static Future<void> init() async {
    // Inicializar zonas horarias
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

    // Crear canal y pedir permiso en Android
    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
      // Si aquí te marca error, COMÉNTALO con //
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

  /// Notificación de prueba
  static Future<void> mostrarNotificacionPrueba() async {
    final details = _notificationDetails();
    await _notificationsPlugin.show(
      999,
      'Prueba de notificación',
      'Si ves esto, las notificaciones locales funcionan ✨',
      details,
    );
  }

  /// 🔴 Versión sencilla: una notificación a la hora de la cita
  /// (si la fecha ya pasó, se mueve 10 segundos al futuro para pruebas)
  static Future<void> programarNotificacionesCita({
    required int idCita,
    required DateTime fechaHoraCita,
    required String paciente,
    required String duenio,
    required String motivo,
  }) async {
    final details = _notificationDetails();

    // Convertimos la fecha a TZDateTime
    tz.TZDateTime cuando = tz.TZDateTime.from(fechaHoraCita, tz.local);
    final tz.TZDateTime ahora = tz.TZDateTime.now(tz.local);

    // Si ya pasó, la movemos 10 segundos al futuro (para que VEAS algo)
    if (!cuando.isAfter(ahora)) {
      print(
        '[CITA] La fecha estaba en el pasado ($cuando), se ajusta unos segundos al futuro',
      );
      cuando = ahora.add(const Duration(seconds: 10));
    }

    final String titulo = 'Cita próxima - ${_formatearHora(cuando)}';
    final String cuerpo =
        'Paciente: $paciente.\nDueño: $duenio\nMotivo: $motivo';

    // ID único derivado de la cita
    final int notifId = (idCita & 0x7fffffff) % 1000000;

    print('[CITA] Programando notificación id=$notifId para $cuando');

    try {
      await _notificationsPlugin.zonedSchedule(
        notifId,
        titulo,
        cuerpo,
        cuando,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
      print('[CITA] ✅ Notificación programada correctamente');
    } catch (e) {
      print('[CITA] ❌ ERROR al programar notificación: $e');
    }

    final pendientes = await _notificationsPlugin.pendingNotificationRequests();
    print('Pendientes: ${pendientes.length}');
    for (final p in pendientes) {
      print('  - id=${p.id}, title=${p.title}');
    }
  }
}
