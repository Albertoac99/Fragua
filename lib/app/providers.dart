import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/models/user_profile.dart';

/// Se sobreescribe en main() con la BD real (asset) y en tests con memoria.
final databaseProvider = Provider<FraguaDatabase>((ref) {
  throw UnimplementedError('databaseProvider debe sobreescribirse');
});

final profileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(databaseProvider).loadProfile();
});

final exerciseCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.select(db.exercises).get();
  return rows.length;
});
