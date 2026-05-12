import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class NotificationService {
  // ── Inisialisasi ────────────────────────────────────────────────────────────
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        // Channel 1: Fokus Selesai
        NotificationChannel(
          channelGroupKey: 'tsg_channel_group',
          channelKey: 'focus_channel',
          channelName: 'Focus Completed',
          channelDescription: 'Notifikasi saat sesi fokus selesai',
          defaultColor: AppColors.primary,
          ledColor: AppColors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),

        // Channel 2: Pengingat Istirahat Berkala
        NotificationChannel(
          channelGroupKey: 'tsg_channel_group',
          channelKey: 'rest_channel',
          channelName: 'Rest Reminder',
          channelDescription: 'Pengingat untuk istirahat secara berkala',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),

        // Channel 3: Peringatan Overload
        NotificationChannel(
          channelGroupKey: 'tsg_channel_group',
          channelKey: 'overload_channel',
          channelName: 'Overload Warning',
          channelDescription: 'Peringatan jika kamu bekerja terlalu lama',
          defaultColor: const Color(0xFFFF5722),
          ledColor: Colors.orange,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),

        // Channel 4: [BARU] Kesehatan Mata — 20/20/20 Rule
        NotificationChannel(
          channelGroupKey: 'tsg_channel_group',
          channelKey: 'eye_health_channel',
          channelName: 'Eye Health',
          channelDescription: 'Pengingat aturan 20/20/20 untuk kesehatan mata',
          defaultColor: const Color(0xFF00ACC1),
          ledColor: Colors.cyan,
          importance: NotificationImportance.Default,
          channelShowBadge: false,
          playSound: false, // notifikasi ringan, tanpa suara mengganggu
        ),

        // Channel 5: [BARU] Istirahat Panjang — setelah 2 jam fokus
        NotificationChannel(
          channelGroupKey: 'tsg_channel_group',
          channelKey: 'long_break_channel',
          channelName: 'Long Break Reminder',
          channelDescription: 'Pengingat istirahat panjang setelah 2 jam fokus',
          defaultColor: AppColors.primaryDarker,
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'tsg_channel_group',
          channelGroupName: 'TouchSomeGrass Notifications',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  // ── Listeners ───────────────────────────────────────────────────────────────
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('TSG Notif created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('TSG Notif displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('TSG Notif dismissed: ${receivedNotification.title}');
    if (receivedNotification.channelKey == 'rest_channel') {
      await cancelRestReminders();
    }
  }

  static Future<void> _onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('TSG Notif action: ${receivedNotification.title}');
    final payload = receivedNotification.payload;
    if (payload == null) return;
    if (payload['action'] == 'start_rest') {
      await cancelRestReminders();
    }
  }

  // ── NOTIFIKASI 1: Sesi Fokus Selesai ────────────────────────────────────────
  static Future<void> notifyFocusDone({
    required int points,
    required int minutes,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'focus_channel',
        title: '🌿 Sesi Fokus Selesai!',
        body: 'Kerja bagus! Kamu fokus $minutes menit dan mendapat +$points poin.',
        notificationLayout: NotificationLayout.Default,
        payload: {'type': 'focus_done'},
      ),
    );
  }

  // ── NOTIFIKASI 2: Pengingat Istirahat Terjadwal ──────────────────────────────
  static Future<void> scheduleRestReminder({
    Duration interval = const Duration(minutes: 25),
  }) async {
    await cancelRestReminders();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'rest_channel',
        title: '😌 Waktunya Istirahat!',
        body: 'Kamu sudah fokus cukup lama. Ambil napas, minum air, atau jalan sebentar.',
        notificationLayout: NotificationLayout.Default,
        payload: {'action': 'start_rest', 'type': 'rest_reminder'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'start_rest',
          label: 'Mulai Istirahat',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'dismiss_rest',
          label: 'Nanti',
          actionType: ActionType.DismissAction,
        ),
      ],
      schedule: NotificationInterval(
        interval: interval,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
        repeats: true,
      ),
    );
  }

  // ── NOTIFIKASI 3: Overload Kerja ─────────────────────────────────────────────
  static Future<void> notifyOverload({required int elapsedMinutes}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'overload_channel',
        title: '⚠️ Kamu Mungkin Overload!',
        body:
            'Kamu sudah bekerja $elapsedMinutes menit non-stop. '
            'Tubuh dan pikiranmu butuh jeda. TouchSomeGrass dulu yuk!',
        notificationLayout: NotificationLayout.BigText,
        payload: {'type': 'overload', 'minutes': '$elapsedMinutes'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'take_break',
          label: '🌿 Istirahat Sekarang',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  // ── NOTIFIKASI 4 : Kesehatan Mata — Menit ke-20 ──────────────────────
  /// Dipanggil oleh TimerProvider saat _elapsedSeconds == 1200 (20 menit).
  /// Notifikasi ringan tanpa suara: ingatkan 20/20/20 rule.
  static Future<void> notifyEyeHealth() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4,
        channelKey: 'eye_health_channel',
        title: '👁️ Istirahatkan Matamu',
        body: 'Lihat objek berjarak 6 meter selama 20 detik untuk mengurangi ketegangan mata!',
        notificationLayout: NotificationLayout.Default,
        payload: {'type': 'eye_health'},
      ),
    );
  }

  // ── NOTIFIKASI 5 : Istirahat Panjang — Menit ke-120 ──────────────────
  /// Dipanggil oleh TimerProvider saat _elapsedSeconds == 7200 (120 menit).
  static Future<void> notifyLongBreak() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 5,
        channelKey: 'long_break_channel',
        title: '🟢 Waktunya Istirahat Panjang!',
        body:
            'Kamu sudah fokus 2 jam! Istirahatlah 15–30 menit: '
            'makan, peregangan, atau jalan keluar.',
        notificationLayout: NotificationLayout.BigText,
        payload: {'type': 'long_break'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'start_long_break',
          label: '🌿 Istirahat Sekarang',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  // ── HELPER ───────────────────────────────────────────────────────────────────
  static Future<void> cancelRestReminders() async {
    await AwesomeNotifications().cancelSchedule(2);
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
