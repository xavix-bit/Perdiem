import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: PerdiemApp()));
}

class PerdiemApp extends ConsumerWidget {
  const PerdiemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorProvider);

    return MaterialApp(
      title: 'Perdiem',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
