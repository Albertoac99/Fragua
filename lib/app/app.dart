import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'providers.dart';

class FraguaApp extends StatelessWidget {
  const FraguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fragua',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF58CC02),
        useMaterial3: true,
      ),
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return profile.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (p) => p == null ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
