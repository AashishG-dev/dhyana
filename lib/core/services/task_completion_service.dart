// lib/core/services/task_completion_service.dart
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskCompletionService {
  final ProviderRef _ref;

  TaskCompletionService(this._ref);

  Future<void> completeTask(String taskId) async {
    final userProfile = _ref.read(currentUserProfileProvider).value;
    if (userProfile != null) {
      final completedTaskIds = List<String>.from(userProfile.completedTaskIds);
      if (!completedTaskIds.contains(taskId)) {
        completedTaskIds.add(taskId);
        final updatedUser =
        userProfile.copyWith(completedTaskIds: completedTaskIds);
        await _ref
            .read(userProfileNotifierProvider.notifier)
            .updateUserProfile(updatedUser);

        // This line forces the user profile to refresh across the app
        _ref.invalidate(currentUserProfileProvider);
      }
    }
  }
}

final taskCompletionServiceProvider = Provider<TaskCompletionService>((ref) {
  return TaskCompletionService(ref);
});