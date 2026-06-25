import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'services/db/app_database.dart';
import 'services/media/media_cache.dart';
import 'services/voice/voice_cues.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      voiceProvider.overrideWithValue(TtsVoiceCues()),
      mediaCacheProvider.overrideWithValue(HttpMediaCache()),
    ],
    child: const FraguaApp(),
  ));
}
