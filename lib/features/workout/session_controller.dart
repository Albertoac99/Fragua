import 'package:flutter/foundation.dart';

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

class WorkoutSessionController extends ChangeNotifier {
  WorkoutSessionController({
    required this.db,
    required PlanDay day,
    required Map<String, double> initialWeights,
  }) : _state = WorkoutSessionState(
          day: day,
          exerciseIndex: 0,
          weights: Map<String, double>.from(initialWeights),
          loggedReps: {},
          finished: false,
        );

  final FraguaDatabase db;
  WorkoutSessionState _state;
  WorkoutSessionState get state => _state;

  int _prCount = 0;
  /// Nº de ejercicios cuyo peso de trabajo subió en [finish] (PRs de la sesión).
  int get prCount => _prCount;

  void setWeight(double weight) {
    _state = _state.copyWith(
      weights: {..._state.weights, _state.current.exerciseId: weight},
    );
    notifyListeners();
  }

  void logSet(int reps) {
    final id = _state.current.exerciseId;
    final repsList = [...(_state.loggedReps[id] ?? const <int>[]), reps];
    _state = _state.copyWith(loggedReps: {..._state.loggedReps, id: repsList});
    notifyListeners();
  }

  void nextExercise() {
    if (!_state.isLastExercise) {
      _state = _state.copyWith(exerciseIndex: _state.exerciseIndex + 1);
      notifyListeners();
    }
  }

  Future<void> finish() async {
    for (final e in _state.day.exercises) {
      final reps = _state.loggedReps[e.exerciseId];
      if (reps == null || reps.isEmpty) continue;
      final weight = _state.weights[e.exerciseId] ?? 0;
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
      if (result.nextWeight > weight) _prCount++;
      await db.saveExerciseState(
          e.exerciseId, result.nextWeight, result.nextStallCount);
    }
    _state = _state.copyWith(finished: true);
    notifyListeners();
  }
}
