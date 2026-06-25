import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/models/exercise.dart';
import 'package:fragua/features/settings/settings_screen.dart';
import 'package:fragua/services/media/media_cache.dart';

class SpyCache implements MediaCache {
  bool cleared = false;
  @override
  Future<File?> getIfCached(String url) async => null;
  @override
  Future<File?> fetch(String url) async => null;
  @override
  Future<int> sizeBytes() async => 0;
  @override
  Future<void> clear() async => cleared = true;
}

void main() {
  testWidgets('vaciar caché llama a clear()', (tester) async {
    final spy = SpyCache();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        mediaCacheProvider.overrideWithValue(spy),
        catalogProvider.overrideWith((ref) async => <Exercise>[]),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clear-cache')));
    await tester.pumpAndSettle();

    expect(spy.cleared, isTrue);
  });
}
