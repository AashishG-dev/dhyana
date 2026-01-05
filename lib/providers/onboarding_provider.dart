// lib/providers/onboarding_provider.dart
import 'package:dhyana/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides a boolean indicating if the user has seen the onboarding flow.
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  // Use a temporary variable to avoid race conditions with other providers
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getBool('hasSeenOnboarding');
});

// Provider to check for the temporary logout flag
final justLoggedOutProvider = Provider<bool>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getBool('justLoggedOut');
});

// Notifier to update the onboarding and logout status.
final onboardingNotifierProvider = NotifierProvider<OnboardingNotifier, void>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<void> {
  late StorageService _storageService;

  @override
  void build() {
    _storageService = ref.watch(storageServiceProvider);
  }

  Future<void> setOnboardingSeen() async {
    await _storageService.setBool('hasSeenOnboarding', true);
    // Invalidate the provider to force a re-read of the new value
    ref.invalidate(onboardingStatusProvider);
  }

  // A new method to handle the post-logout state
  Future<void> handleLogoutRedirect() async {
    await _storageService.setBool('justLoggedOut', true);
    // Invalidate providers to trigger the router's refresh mechanism
    ref.invalidate(onboardingStatusProvider);
    ref.invalidate(justLoggedOutProvider);
  }

  // A method to clear the logout flag after it has been used
  Future<void> clearLogoutFlag() async {
    await _storageService.remove('justLoggedOut');
    ref.invalidate(justLoggedOutProvider);
  }
}