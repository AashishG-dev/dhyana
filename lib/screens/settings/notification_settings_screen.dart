// lib/screens/settings/notification_settings_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/services/notification_service.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  TimeOfDay? _meditationTime;
  TimeOfDay? _journalTime;
  bool _meditationEnabled = false;
  bool _journalEnabled = false;

  final NotificationService _notificationService = NotificationService();
  static const String _meditationTimeKey = 'meditation_reminder_time';
  static const String _journalTimeKey = 'journal_reminder_time';
  static const String _meditationEnabledKey = 'meditation_reminder_enabled';
  static const String _journalEnabledKey = 'journal_reminder_enabled';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _meditationTime = _getTimeFromString(prefs.getString(_meditationTimeKey));
      _journalTime = _getTimeFromString(prefs.getString(_journalTimeKey));
      _meditationEnabled = prefs.getBool(_meditationEnabledKey) ?? false;
      _journalEnabled = prefs.getBool(_journalEnabledKey) ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value == null) {
      await prefs.remove(key);
    }
  }

  TimeOfDay? _getTimeFromString(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickTime({required bool isMeditation}) async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Permission to schedule exact alarms is required.'),
            backgroundColor: Colors.red,
          ));
        }
        return;
      }
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: (isMeditation ? _meditationTime : _journalTime) ?? TimeOfDay.now(),
      helpText: 'Select Reminder Time',
    );

    if (pickedTime != null) {
      setState(() {
        if (isMeditation) {
          _meditationTime = pickedTime;
        } else {
          _journalTime = pickedTime;
        }
      });

      await _saveSetting(isMeditation ? _meditationTimeKey : _journalTimeKey, '${pickedTime.hour}:${pickedTime.minute}');

      await _notificationService.scheduleDailyNotification(
        id: isMeditation ? 0 : 1,
        title: isMeditation ? '🧘 Time for your daily meditation!' : '📖 Time for your daily journal!',
        body: isMeditation ? 'A few moments of calm can make a world of difference.' : 'Take a moment to reflect on your day.',
        time: pickedTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isMeditation ? "Meditation" : "Journal"} reminder set for ${pickedTime.format(context)}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleReminder({required bool isEnabled, required bool isMeditation}) async {
    setState(() {
      if (isMeditation) {
        _meditationEnabled = isEnabled;
        if (!isEnabled) _meditationTime = null;
      } else {
        _journalEnabled = isEnabled;
        if (!isEnabled) _journalTime = null;
      }
    });

    await _saveSetting(isMeditation ? _meditationEnabledKey : _journalEnabledKey, isEnabled);

    if (!isEnabled) {
      await _notificationService.cancelNotification(isMeditation ? 0 : 1);
      await _saveSetting(isMeditation ? _meditationTimeKey : _journalTimeKey, null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isMeditation ? "Meditation" : "Journal"} reminder has been turned off.')),
        );
      }
    } else {
      _pickTime(isMeditation: isMeditation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notification Reminders',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF212121)]
                : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildReminderCard(
              context: context,
              title: 'Meditation Reminder',
              icon: Icons.self_improvement,
              isEnabled: _meditationEnabled,
              selectedTime: _meditationTime,
              onToggle: (value) => _toggleReminder(isEnabled: value, isMeditation: true),
              onTimeTap: () => _pickTime(isMeditation: true),
            ),
            const SizedBox(height: 24),
            _buildReminderCard(
              context: context,
              title: 'Journal Reminder',
              icon: Icons.edit_note,
              isEnabled: _journalEnabled,
              selectedTime: _journalTime,
              onToggle: (value) => _toggleReminder(isEnabled: value, isMeditation: false),
              onTimeTap: () => _pickTime(isMeditation: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isEnabled,
    required TimeOfDay? selectedTime,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge,
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (isEnabled) ...[
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.access_time_filled_rounded),
                title: const Text('Scheduled Time'),
                subtitle: Text(
                  selectedTime?.format(context) ?? 'Not set',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: onTimeTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}