import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart' as app_providers;
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MoodTrackerApp(),
    ),
  );
}

class MoodTrackerApp extends ConsumerWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(app_providers.themeModeProvider);

    return MaterialApp.router(
      title: 'Mood Tracker',

      // Theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: _mapThemeMode(themeMode),

      // Router configuration
      routerConfig: ref.watch(routerProvider),
    );
  }

  ThemeMode _mapThemeMode(app_providers.ThemeMode mode) {
    switch (mode) {
      case app_providers.ThemeMode.light:
        return ThemeMode.light;
      case app_providers.ThemeMode.dark:
        return ThemeMode.dark;
      case app_providers.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
