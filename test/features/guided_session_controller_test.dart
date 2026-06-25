import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/session/guided_session.dart';
import 'package:fragua/features/workout/guided_session_controller.dart';
import 'package:fragua/services/voice/voice_cues.dart';

class RecordingVoice implements VoiceCues {
  final List<String> said = [];
  @override
  Future<void> say(String text) async => said.add(text);
}

PlanDay circuit() => const PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 2,
      exercises: [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 1,
          workSeconds: 2,
        ),
      ],
    );

void main() {
  test('recorre el timeline, anuncia rondas y al terminar progresa+persiste', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // racha previa 1 => al completar (umbral 2) debe progresar el tiempo.
    await db.saveGuidedState('Circuito', 30, 2, 1);

    final voice = RecordingVoice();
    final day = circuit();
    final timeline = buildGuidedTimeline(day, workSecondsOverride: 2, roundsOverride: 2);
    // timeline: [work2(r1), rest1(r1), work2(r2)] => 5 segundos en total.
    final c = GuidedSessionController(
      db: db,
      voice: voice,
      day: day,
      timeline: timeline,
      initialWorkSeconds: 30,
      initialRounds: 2,
    );

    c.start();
    expect(c.state.currentStep!.label, 'Sentadilla');
    expect(c.state.remainingSeconds, 2);

    // 5 ticks consumen los 3 segmentos (2+1+2).
    for (var i = 0; i < 5; i++) {
      c.tick();
    }
    expect(c.state.finished, isTrue);

    await c.finish();
    final gs = await db.guidedState('Circuito');
    expect(gs!.workSeconds, 35); // progresó el tiempo (+5) por completar
    expect(gs.streak, 0);

    // Anunció la segunda ronda por voz en algún momento.
    expect(voice.said.any((s) => s.contains('Ronda 2 de 2')), isTrue);
  });

  test('finish() es idempotente (no progresa dos veces)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveGuidedState('Circuito', 30, 2, 1);

    final day = circuit();
    final c = GuidedSessionController(
      db: db,
      voice: SilentVoiceCues(),
      day: day,
      timeline: buildGuidedTimeline(day, workSecondsOverride: 2, roundsOverride: 2),
      initialWorkSeconds: 30,
      initialRounds: 2,
    );
    c.start();
    for (var i = 0; i < 5; i++) {
      c.tick();
    }
    await c.finish();
    await c.finish(); // segunda llamada: no debe volver a progresar
    final gs = await db.guidedState('Circuito');
    expect(gs!.workSeconds, 35);
  });

  test('AMRAP: cuenta rondas a mano y completa si alcanza el objetivo', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const day = PlanDay(
      name: 'AMRAP',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 2, // objetivo de rondas
      totalSeconds: 3,
      exercises: [],
    );
    final c = GuidedSessionController(
      db: db,
      voice: SilentVoiceCues(),
      day: day,
      timeline: const [],
      initialWorkSeconds: 30,
      initialRounds: 2,
    );
    c.start();
    expect(c.state.isAmrap, isTrue);
    expect(c.state.remainingSeconds, 3);

    c.addRound();
    c.addRound();
    expect(c.state.completedRounds, 2);

    for (var i = 0; i < 3; i++) {
      c.tick(); // agota el tiempo
    }
    expect(c.state.finished, isTrue);

    await c.finish();
    // completó el objetivo (2 >= 2): racha sube a 1 (umbral 2, aún sin progresar).
    final gs = await db.guidedState('AMRAP');
    expect(gs!.streak, 1);
    expect(gs.rounds, 2);
  });
}
