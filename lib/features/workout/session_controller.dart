import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/plan.dart';
import '../../core/progression/progression.dart';

class WorkoutSessionState {
  final PlanDay day;
  final int exerciseIndex;
  final Map<String, double> weights;
  final Map<String, List<int>> loggedReps;
  final bool finished;

  const WorkoutSessionState({
    required this.day,
    required this.exerciseIndex,
    required this.weights,
    required this.loggedReps,
    required this.finished,
  });

  PlanExercise get current => day.exercises[exerciseIndex];
  bool get isLastExercise => exerciseIndex >= day.exercises.length - 1;
  List<int> get currentReps => loggedReps[current.exerciseId] ?? const [];

  WorkoutSessionState copyWith({
    int? exerciseIndex,
    Map<String, double>? weights,
    Map<String, List<int>>? loggedReps,
    bool? finished,
  }) {
    return WorkoutSessionState(
      day: day,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      weights: weights ?? this.weights,
      loggedReps: loggedReps ?? this.loggedReps,
      finished: finished ?? this.finished,
    );
  }
}

class WorkoutSessionController extends StateNotifier<WorkoutSessionState> {
  WorkoutSessionController({
    required this.db,
    required PlanDay day,
    required Map<String, double> initialWeights,
  }) : super(WorkoutSessionState(
          day: day,
          exerciseIndex: 0,
          weights: Map<String, double>.from(initialWeights),
          loggedReps: {},
          finished: false,
        ));

  final FraguaDatabase db;

  void setWeight(double weight) {
    state = state.copyWith(
      weights: {...state.weights, state.current.exerciseId: weight},
    );
  }

  void logSet(int reps) {
    final id = state.current.exerciseId;
    final repsList = [...(state.loggedReps[id] ?? const <int>[]), reps];
    state = state.copyWith(loggedReps: {...state.loggedReps, id: repsList});
  }

  void nextExercise() {
    if (!state.isLastExercise) {
      state = state.copyWith(exerciseIndex: state.exerciseIndex + 1);
    }
  }

  Future<void> finish() async {
    for (final e in state.day.exercises) {
      final reps = state.loggedReps[e.exerciseId];
      if (reps == null || reps.isEmpty) continue;
      final weight = state.weights[e.exerciseId] ?? 0;
      final prev = await db.exerciseState(e.exerciseId);
      final result = decideProgression(
        repLow: e.repLow,
        repHigh: e.repHigh,
        currentWeight: weight,
        repsPerSet: reps,
        targetSets: e.sets,
        increment: 2.5,
        stallCount: prev?.stall ?? 0,
      );
      await db.saveExerciseState(
          e.exerciseId, result.nextWeight, result.nextStallCount);
    }
    state = state.copyWith(finished: true);
  }
}
