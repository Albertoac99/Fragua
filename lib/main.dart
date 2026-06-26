import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'features/notifications/notifications_service.dart';
import 'services/db/app_database.dart';
import 'services/media/media_cache.dart';
import 'services/notifications/notifier.dart';
import 'services/voice/voice_cues.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();

  final notifier = LocalNotifier();
  try {
    await notifier.init();
    await NotificationsService(notifier: notifier, db: db)
        .reschedule(DateTime.now());
  } catch (_) {
    // Degradado: si el plugin falla o se deniega el permiso, la app sigue.
  }

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      voiceProvider.overrideWithValue(TtsVoiceCues()),
      mediaCacheProvider.overrideWithValue(HttpMediaCache()),
      notifierProvider.overrideWithValue(notifier),
    ],
    child: const FraguaApp(),
  ));
}
