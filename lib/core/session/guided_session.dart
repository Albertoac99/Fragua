import '../models/plan.dart';

/// Tipo de segmento de una sesión guiada.
enum StepKind { work, rest }

/// Un segmento de la línea de tiempo de una sesión guiada.
class SessionStep {
  final StepKind kind;
  final String exerciseId; // id del ejercicio (work); '' en los descansos
  final int seconds;
  final String label; // nombre del ejercicio (work) o etiqueta de descanso (rest)
  final int round; // ronda actual, 1-based
  final int totalRounds;

  const SessionStep({
    required this.kind,
    required this.exerciseId,
    required this.seconds,
    required this.label,
    required this.round,
    required this.totalRounds,
  });
}

/// Construye la línea de tiempo determinista de un día guiado de tipo
/// circuito/intervalos: por cada ronda, cada ejercicio genera un segmento de
/// trabajo ([workSecondsOverride] ?? `exercise.workSeconds` ?? [defaultWorkSeconds])
/// seguido de uno de descanso (`exercise.restSeconds`). Se omite el descanso
/// final (tras el último ejercicio de la última ronda).
///
/// AMRAP no tiene timeline fijo (se cuenta a contrarreloj con rondas manuales),
/// por lo que devuelve una lista vacía.
List<SessionStep> buildGuidedTimeline(
  PlanDay day, {
  int? workSecondsOverride,
  int? roundsOverride,
  int defaultWorkSeconds = 40,
  String restLabel = 'Descanso',
}) {
  if (day.format == WorkoutFormat.amrap) return const [];
  final rounds = roundsOverride ?? day.rounds;
  final steps = <SessionStep>[];
  for (var r = 1; r <= rounds; r++) {
    for (final e in day.exercises) {
      final work = workSecondsOverride ?? e.workSeconds ?? defaultWorkSeconds;
      steps.add(SessionStep(
        kind: StepKind.work,
        exerciseId: e.exerciseId,
        seconds: work,
        label: e.exerciseName,
        round: r,
        totalRounds: rounds,
      ));
      steps.add(SessionStep(
        kind: StepKind.rest,
        exerciseId: '',
        seconds: e.restSeconds,
        label: restLabel,
        round: r,
        totalRounds: rounds,
      ));
    }
  }
  if (steps.isNotEmpty) steps.removeLast(); // sin descanso tras el último trabajo
  return steps;
}
