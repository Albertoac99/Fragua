import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/db/database.dart';

/// Abre la [FraguaDatabase] copiando el catálogo bundleado a una ubicación
/// escribible la primera vez (patrón "prepopulated database"). drift crea
/// entonces las tablas de usuario que falten vía MigrationStrategy.
Future<FraguaDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'fragua.sqlite'));
  if (!await file.exists()) {
    final data = await rootBundle.load('assets/exercise_db.sqlite');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await file.writeAsBytes(bytes, flush: true);
  }
  return FraguaDatabase(NativeDatabase(file));
}
