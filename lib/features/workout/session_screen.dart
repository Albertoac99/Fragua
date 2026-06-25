import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';
import '../exercise/exercise_demo.dart';
import 'session_controller.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.day});
  final PlanDay day;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  WorkoutSessionController? _c;
  int _reps = 12;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final weights = <String, double>{};
    for (final e in widget.day.exercises) {
      final st = await db.exerciseState(e.exerciseId);
      weights[e.exerciseId] = st?.weight ?? 20; // 20 kg por defecto
    }
    if (mounted) {
      setState(() {
        _c = WorkoutSessionController(
            db: db, day: widget.day, initialWeights: weights);
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _c!.finish();
    final st = _c!.state;
    final units = st.loggedReps.values.fold<int>(0, (a, b) => a + b.length);
    await ref.read(leaguesServiceProvider).awardForSession(
          unitsCompleted: units,
          prCount: _c!.prCount,
          completed: true,
          now: DateTime.now(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _c;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.day.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final voice = ref.read(voiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.name)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final st = controller.state;
          final ex = st.current;
          final done = st.currentReps.length;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge),
                ExerciseDemo(exerciseId: ex.exerciseId),
                Text('Objetivo: ${ex.sets} x ${ex.repLow}-${ex.repHigh}'),
                Text('Series hechas: $done / ${ex.sets}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Reps: '),
                    IconButton(
                      onPressed: () =>
                          setState(() => _reps = (_reps - 1).clamp(0, 50)),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_reps'),
                    IconButton(
                      onPressed: () =>
                          setState(() => _reps = (_reps + 1).clamp(0, 50)),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                FilledButton(
                  key: const Key('log-set'),
                  onPressed: () {
                    controller.logSet(_reps);
                    voice.say('Descanso ${ex.restSeconds} segundos');
                  },
                  child: const Text('Registrar serie'),
                ),
                const Spacer(),
                if (!st.isLastExercise)
                  OutlinedButton(
                    onPressed: controller.nextExercise,
                    child: const Text('Siguiente ejercicio'),
                  ),
                FilledButton(
                  key: const Key('finish-session'),
                  onPressed: _finish,
                  child: const Text('Terminar entreno'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
