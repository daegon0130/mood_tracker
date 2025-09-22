import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode provider
enum ThemeMode { light, dark, system }

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// App initialization provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Any app initialization logic here
  await Future.delayed(
      const Duration(milliseconds: 500)); // Simulate initialization
});

final selectedTabProvider = StateProvider<int>((ref) => 0);
