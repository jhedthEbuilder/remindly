import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_data.dart';

class ReminderService {
  static const String baseUrl = 'http://192.168.100.42/remindly_api/api/reminder';
  static const String alertBaseUrl = 'http://192.168.100.42/remindly_api/api/alert';

  // ✅ OFFLINE MODE - set to true for testing without backend
  static const bool isOfflineMode = true;

  // Create reminder (automatically creates 3 alerts)
  static Future<int> createReminder({
    required int userId,
    required String title,
    String? description,
    required String reminderDate,
    required String reminderTime,
    String repeatType = 'Never',
    int? checklistId,
  }) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 500));
        print('✅ Mock: Reminder "$title" created (offline mode)');
        return 1;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create_reminder.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'description': description,
          'reminder_date': reminderDate,
          'reminder_time': reminderTime,
          'repeat_type': repeatType,
          'checklist_id': checklistId,
        }),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['reminder_id'];
        }
      }
      throw Exception('Failed to create reminder');
    } catch (e) {
      print('Error creating reminder: $e');
      if (isOfflineMode) {
        return 1;
      }
      throw Exception('Error: $e');
    }
  }

  // Get all reminders for user
  static Future<List<ReminderModel>> getUserReminders(int userId) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 500));
        return [
          ReminderModel(
            id: 1,
            title: 'Doctor Appointment',
            description: 'Regular checkup',
            reminderDate: '2026-04-20',
            reminderTime: '10:00:00',
            repeatType: 'Never',
          ),
          ReminderModel(
            id: 2,
            title: 'Project Deadline',
            description: 'Mobile app project',
            reminderDate: '2026-04-25',
            reminderTime: '14:30:00',
            repeatType: 'Weekly',
          ),
        ];
      }

      final response = await http.post(
        Uri.parse('$baseUrl/get_reminders.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final reminders = <ReminderModel>[];
          for (var reminder in data['data']) {
            reminders.add(ReminderModel(
              id: reminder['id'],
              title: reminder['title'],
              description: reminder['description'],
              checklistId: reminder['checklist_id'],
              reminderDate: reminder['reminder_date'],
              reminderTime: reminder['reminder_time'],
              repeatType: reminder['repeat_type'],
              active: reminder['active'],
              createdAt: DateTime.tryParse(reminder['created_at'] ?? ''),
            ));
          }
          return reminders;
        }
      }
      return [];
    } catch (e) {
      print('Error in getUserReminders: $e');
      if (isOfflineMode) {
        return [
          ReminderModel(
            id: 1,
            title: 'Doctor Appointment',
            description: 'Regular checkup',
            reminderDate: '2026-04-20',
            reminderTime: '10:00:00',
            repeatType: 'Never',
          ),
        ];
      }
      return [];
    }
  }

  // Update reminder
  static Future<bool> updateReminder({
    required int reminderId,
    required String title,
    String? description,
    required String reminderDate,
    required String reminderTime,
    String repeatType = 'Never',
    bool active = true,
  }) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 300));
        return true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/update_reminder.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reminder_id': reminderId,
          'title': title,
          'description': description,
          'reminder_date': reminderDate,
          'reminder_time': reminderTime,
          'repeat_type': repeatType,
          'active': active ? 1 : 0,
        }),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating reminder: $e');
      if (isOfflineMode) {
        return true;
      }
      throw Exception('Error: $e');
    }
  }

  // Delete reminder
  static Future<bool> deleteReminder(int reminderId) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 300));
        return true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delete_reminder.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reminder_id': reminderId}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting reminder: $e');
      if (isOfflineMode) {
        return true;
      }
      throw Exception('Error: $e');
    }
  }

  // Get all alerts for user
  static Future<List<AlertModel>> getUserAlerts(int userId) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 500));
        return [
          AlertModel(
            id: 1,
            reminderId: 1,
            alertTitle: 'Doctor Appointment',
            alertDate: '2026-04-20',
            alertTime: '09:30:00',
            alertType: '30-mins',
          ),
          AlertModel(
            id: 2,
            reminderId: 2,
            alertTitle: 'Project Deadline',
            alertDate: '2026-04-25',
            alertTime: '14:15:00',
            alertType: '15-mins',
          ),
        ];
      }

      final response = await http.post(
        Uri.parse('$alertBaseUrl/get_alerts.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final alerts = <AlertModel>[];
          for (var alert in data['data']) {
            alerts.add(AlertModel(
              id: alert['id'],
              reminderId: alert['reminder_id'],
              alertTitle: alert['alert_title'],
              alertDate: alert['alert_date'],
              alertTime: alert['alert_time'],
              alertType: alert['alert_type'],
              isRead: alert['is_read'],
              createdAt: DateTime.tryParse(alert['created_at'] ?? ''),
            ));
          }
          return alerts;
        }
      }
      return [];
    } catch (e) {
      print('Error in getUserAlerts: $e');
      if (isOfflineMode) {
        return [
          AlertModel(
            id: 1,
            reminderId: 1,
            alertTitle: 'Doctor Appointment',
            alertDate: '2026-04-20',
            alertTime: '09:30:00',
            alertType: '30-mins',
          ),
        ];
      }
      return [];
    }
  }

  // Mark alert as read
  static Future<bool> markAlertRead(int alertId) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 300));
        return true;
      }

      final response = await http.post(
        Uri.parse('$alertBaseUrl/mark_alert_read.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'alert_id': alertId}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking alert as read: $e');
      if (isOfflineMode) {
        return true;
      }
      throw Exception('Error: $e');
    }
  }

  // Delete alert
  static Future<bool> deleteAlert(int alertId) async {
    try {
      if (isOfflineMode) {
        await Future.delayed(Duration(milliseconds: 300));
        return true;
      }

      final response = await http.post(
        Uri.parse('$alertBaseUrl/delete_alert.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'alert_id': alertId}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting alert: $e');
      if (isOfflineMode) {
        return true;
      }
      throw Exception('Error: $e');
    }
  }
}