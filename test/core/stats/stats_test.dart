import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/stats/exercise_log.dart';
import 'package:fragua/core/stats/stats.dart';

ExerciseLog log(double w, int maxReps, int totalReps, DateTime at) => ExerciseLog(
      exerciseId: 'bench',
      exerciseName: 'Bench',
      performedAt: at,
      weight: w,
      totalReps: totalReps,
      sets: 3,
      maxReps: maxReps,
    );

void main() {
  test('Epley: 100kg x 10 ≈ 133.3', () {
    expect(estimatedOneRm(100, 10), closeTo(133.33, 0.01));
    expect(estimatedOneRm(60, 1), closeTo(62.0, 0.01));
  });

  test('bestOneRm escoge el máximo estimado', () {
    final logs = [
      log(100, 5, 15, DateTime(2026, 6, 1)), // 100*(1+5/30)=116.67
      log(90, 12, 36, DateTime(2026, 6, 8)), // 90*(1+12/30)=126.0
    ];
    expect(bestOneRm(logs), closeTo(126.0, 0.01));
    expect(bestOneRm(const []), 0);
  });

  test('totalVolume suma peso*reps', () {
    final logs = [
      log(100, 8, 24, DateTime(2026, 6, 1)), // 2400
      log(80, 10, 30, DateTime(2026, 6, 8)), // 2400
    ];
    expect(totalVolume(logs), 4800);
  });

  test('oneRmSeries va ordenada por fecha ascendente', () {
    final logs = [
      log(100, 5, 15, DateTime(2026, 6, 8)),
      log(90, 12, 36, DateTime(2026, 6, 1)),
    ];
    final s = oneRmSeries(logs);
    expect(s.map((e) => e.date).toList(),
        [DateTime(2026, 6, 1), DateTime(2026, 6, 8)]);
    expect(s.first.oneRm, closeTo(126.0, 0.01));
  });
}
