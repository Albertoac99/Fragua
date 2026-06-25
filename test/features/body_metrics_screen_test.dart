import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/stats/body_metrics_screen.dart';

void main() {
  testWidgets('añade una medida y la persiste', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: BodyMetricsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('metric-value')), '80.5');
    await tester.tap(find.byKey(const Key('add-metric')));
    await tester.pumpAndSettle();

    final bw = await db.loadBodyMetrics('bodyweight');
    expect(bw, hasLength(1));
    expect(bw.first.value, 80.5);
  });
}
