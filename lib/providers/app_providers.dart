import 'package:flutter_riverpod/flutter_riverpod.dart';

// Loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error message provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Theme mode provider
enum ThemeMode { light, dark, system }

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// App initialization provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Add any app initialization logic here
  // For example: checking if user is logged in, loading user preferences, etc.
  await Future.delayed(
      const Duration(milliseconds: 500)); // Simulate initialization
});

// Navigation index provider (for bottom navigation)
final navigationIndexProvider = StateProvider<int>((ref) => 0);
