// Notification service temporarily disabled
// We'll re-enable Firebase and notifications after the app runs

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    print('⚠️ Notification service disabled for now');
    // TODO: Re-enable Firebase after app runs
  }

  Future<String> getDeviceToken() async {
    return '';
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    print('Notifications disabled');
  }

  Future<void> cancelNotification(int id) async {}

  Future<void> cancelAllNotifications() async {}
}