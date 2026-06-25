import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import '../../core/models/plan.dart';
import '../../core/progression/guided_progression.dart';
import '../../core/session/guided_session.dart';
import '../../services/voice/voice_cues.dart';

class GuidedSessionState {
  final PlanDay day;
  final List<SessionStep> timeline;
  final int stepIndex;
  final int remainingSeconds;
  final int completedRounds;
  final bool running;
  final bool finished;

  const GuidedSessionState({
    required this.day,
    required this.timeline,
    required this.stepIndex,
    required this.remainingSeconds,
    required this.completedRounds,
    required this.running,
    required this.finished,
  });

  bool get isAmrap => day.format == WorkoutFormat.amrap;

  SessionStep? get currentStep =>
      (!isAmrap && stepIndex >= 0 && stepIndex < timeline.length)
          ? timeline[stepIndex]
          : null;

  SessionStep? get nextStep {
    final n = stepIndex + 1;
    return (!isAmrap && n < timeline.length) ? timeline[n] : null;
  }

  /// Progreso 0..1 (por tiempo en AMRAP; por segmentos en circuito/intervalos).
  double get progress {
    if (isAmrap) {
      final total = day.totalSeconds ?? 0;
      if (total <= 0) return 0;
      return (1 - remainingSeconds / total).clamp(0, 1);
    }
    if (timeline.isEmpty) return 0;
    return (stepIndex / timeline.length).clamp(0, 1);
  }

  GuidedSessionState copyWith({
    int? stepIndex,
    int? remainingSeconds,
    int? completedRounds,
    bool? running,
    bool? finished,
  }) {
    return GuidedSessionState(
      day: day,
      timeline: timeline,
      stepIndex: stepIndex ?? this.stepIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedRounds: completedRounds ?? this.completedRounds,
      running: running ?? this.running,
      finished: finished ?? this.finished,
    );
  }
}

class GuidedSessionController extends ChangeNotifier {
  GuidedSessionController({
    required this.db,
    required this.voice,
    required PlanDay day,
    required List<SessionStep> timeline,
    required this.initialWorkSeconds,
    required this.initialRounds,
  })  : _stepsPerRound = day.exercises.isEmpty ? 1 : day.exercises.length * 2,
        _state = GuidedSessionState(
          day: day,
          timeline: timeline,
          stepIndex: 0,
          remainingSeconds: day.format == WorkoutFormat.amrap
              ? (day.totalSeconds ?? 0)
              : (timeline.isEmpty ? 0 : timeline.first.seconds),
          completedRounds: 0,
          running: false,
          finished: false,
        );

  final FraguaDatabase db;
  final VoiceCues voice;
  final int initialWorkSeconds;
  final int initialRounds;
  final int _stepsPerRound;

  GuidedSessionState _state;
  GuidedSessionState get state => _state;

  bool _reachedEnd = false;
  bool _applied = false;

  void start() {
    if (_state.finished) return;
    _state = _state.copyWith(running: true);
    final s = _state.currentStep;
    if (s != null) voice.say(_announce(0));
    notifyListeners();
  }

  void pause() {
    _state = _state.copyWith(running: false);
    notifyListeners();
  }

  /// AMRAP: el usuario marca una ronda completada.
  void addRound() {
    if (!_state.isAmrap || _state.finished) return;
    final n = _state.completedRounds + 1;
    _state = _state.copyWith(completedRounds: n);
    voice.say('Ronda $n');
    notifyListeners();
  }

  /// Avanza un segundo. La UI lo llama desde un `Timer.periodic`; los tests a mano.
  void tick() {
    if (!_state.running || _state.finished) return;
    final remaining = _state.remainingSeconds - 1;
    if (remaining > 0) {
      _state = _state.copyWith(remainingSeconds: remaining);
      if (remaining <= 3) voice.say('$remaining');
      notifyListeners();
      return;
    }
    // Segmento agotado.
    if (_state.isAmrap) {
      _reachedEnd = true;
      _state =
          _state.copyWith(remainingSeconds: 0, finished: true, running: false);
      notifyListeners();
      return;
    }
    final next = _state.stepIndex + 1;
    if (next >= _state.timeline.length) {
      _reachedEnd = true;
      _state =
          _state.copyWith(remainingSeconds: 0, finished: true, running: false);
      notifyListeners();
      return;
    }
    final step = _state.timeline[next];
    _state = _state.copyWith(stepIndex: next, remainingSeconds: step.seconds);
    voice.say(_announce(next));
    notifyListeners();
  }

  /// Aplica la progresión y persiste el estado del día. Idempotente.
  Future<void> finish() async {
    if (_applied) return;
    _applied = true;
    final completedAll = _state.isAmrap
        ? _state.completedRounds >= _state.day.rounds
        : _reachedEnd;
    final prev = await db.guidedState(_state.day.name);
    final result = decideGuidedProgression(
      completedAll: completedAll,
      workSeconds: initialWorkSeconds,
      rounds: initialRounds,
      streak: prev?.streak ?? 0,
    );
    await db.saveGuidedState(
      _state.day.name,
      result.nextWorkSeconds,
      result.nextRounds,
      result.nextStreak,
    );
    if (!_state.finished) {
      _state = _state.copyWith(finished: true, running: false);
      notifyListeners();
    }
  }

  String _announce(int index) {
    final step = _state.timeline[index];
    if (step.kind == StepKind.rest) return 'Descanso';
    final isRoundStart = index % _stepsPerRound == 0;
    if (!isRoundStart) return 'Siguiente: ${step.label}';
    final last = step.round == step.totalRounds ? 'Última ronda. ' : '';
    return 'Ronda ${step.round} de ${step.totalRounds}. $last${step.label}';
  }
}
