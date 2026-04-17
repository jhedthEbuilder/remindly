// lib/services/app_data.dart
import 'package:flutter/material.dart';

class ChecklistItem {
  int? id; // Database ID
  String text;
  bool checked;
  ChecklistItem({this.id, required this.text, this.checked = false});
}

class ChecklistModel {
  int? id; // Database ID
  String title;
  String category;
  List<ChecklistItem> items;
  bool expanded;
  
  ChecklistModel({
    this.id,
    required this.title,
    required this.category,
    List<ChecklistItem>? items,
    this.expanded = false,
  }) : items = items ?? [];
}

// ✅ FIXED: Updated ReminderModel with correct properties
class ReminderModel {
  int? id;
  String title;
  String? description;
  int? checklistId;
  String reminderDate;
  String reminderTime;
  String repeatType;
  bool active;
  DateTime? createdAt;

  ReminderModel({
    this.id,
    required this.title,
    this.description,
    this.checklistId,
    required this.reminderDate,
    required this.reminderTime,
    this.repeatType = 'Never',
    this.active = true,
    this.createdAt,
  });
}

// ✅ FIXED: Updated AlertModel with correct properties
class AlertModel {
  int? id;
  int? reminderId;
  String alertTitle;
  String alertDate;
  String alertTime;
  String alertType;
  bool isRead;
  DateTime? createdAt;

  AlertModel({
    this.id,
    this.reminderId,
    required this.alertTitle,
    required this.alertDate,
    required this.alertTime,
    required this.alertType,
    this.isRead = false,
    this.createdAt,
  });
}

class AppData {
  AppData._private();
  static final AppData instance = AppData._private();

  final List<ChecklistModel> checklists = [];
  final List<ReminderModel> reminders = [];
  final List<AlertModel> alerts = [];
  final List<String> categories = ['Work', 'School', 'Travel', 'Business', 'Parent', 'Fitness'];
  bool notificationsPermissionGranted = false;
  String selectedTheme = 'Monochromatic Blue';
  String userName = 'Angel';

  void seedIfEmpty() {
    if (checklists.isEmpty) {
      checklists.addAll([
        ChecklistModel(
          title: 'Student Essentials',
          category: 'School',
          items: [
            ChecklistItem(text: 'Textbooks'),
            ChecklistItem(text: 'Laptop'),
            ChecklistItem(text: 'Notebook'),
          ],
        ),
        ChecklistModel(
          title: 'Morning Checklist',
          category: 'School',
          items: [
            ChecklistItem(text: 'Brush Teeth'),
            ChecklistItem(text: 'Make Bed'),
          ],
        ),
      ]);
    }
  }

  void addChecklist(ChecklistModel list) => checklists.insert(0, list);
  void deleteChecklistAt(int index) => checklists.removeAt(index);

  void addReminder(ReminderModel r) => reminders.insert(0, r);
  void deleteReminderAt(int index) => reminders.removeAt(index);

  void addAlert(AlertModel alert) => alerts.insert(0, alert);
  void deleteAlertAt(int index) => alerts.removeAt(index);

  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
    }
  }
}