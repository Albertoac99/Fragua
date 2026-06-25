import 'dart:math' as math;

class GuidedProgressionResult {
  final int nextWorkSeconds;
  final int nextRounds;
  final bool bumpVariant;
  final int nextStreak;
  const GuidedProgressionResult({
    required this.nextWorkSeconds,
    required this.nextRounds,
    required this.bumpVariant,
    required this.nextStreak,
  });
}

/// Auto-regulación del modo guiado (§7.3 de la spec).
///
/// Si el usuario completa todas las rondas/objetivos ([completedAll]) acumula
/// racha; al alcanzar [streakToProgress] aplica **una** mejora y resetea la
/// racha, en este orden:
/// 1. **(a) tiempo/reps**: sube el trabajo [workSecondsStep] s hasta [workSecondsCap];
/// 2. **(c) variante**: si el trabajo ya está al tope y hay variante más difícil
///    ([harderVariantAvailable]), sube de variante y resetea el trabajo a [baseWorkSeconds];
/// 3. **(b) densidad**: si no hay variante, añade una ronda hasta [maxRounds] y
///    resetea el trabajo a [baseWorkSeconds].
/// Si no completa, **resetea la racha** y mantiene los parámetros.
GuidedProgressionResult decideGuidedProgression({
  required bool completedAll,
  required int workSeconds,
  required int rounds,
  required int streak,
  bool harderVariantAvailable = false,
  int baseWorkSeconds = 30,
  int workSecondsCap = 60,
  int workSecondsStep = 5,
  int maxRounds = 6,
  int streakToProgress = 2,
}) {
  GuidedProgressionResult keep({
    int? streakOverride,
    int? work,
    int? rounds_,
    bool variant = false,
  }) =>
      GuidedProgressionResult(
        nextWorkSeconds: work ?? workSeconds,
        nextRounds: rounds_ ?? rounds,
        bumpVariant: variant,
        nextStreak: streakOverride ?? streak,
      );

  if (!completedAll) return keep(streakOverride: 0);

  final newStreak = streak + 1;
  if (newStreak < streakToProgress) return keep(streakOverride: newStreak);

  // Listo para progresar: aplica una mejora y resetea la racha.
  if (workSeconds < workSecondsCap) {
    return keep(
      work: math.min(workSeconds + workSecondsStep, workSecondsCap),
      streakOverride: 0,
    );
  }
  if (harderVariantAvailable) {
    return keep(work: baseWorkSeconds, variant: true, streakOverride: 0);
  }
  if (rounds < maxRounds) {
    return keep(work: baseWorkSeconds, rounds_: rounds + 1, streakOverride: 0);
  }
  return keep(streakOverride: 0); // techo: nada que mejorar
}
