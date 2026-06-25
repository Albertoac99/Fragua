class ProgressionResult {
  final double nextWeight;
  final int nextStallCount;
  final bool deload;
  const ProgressionResult({
    required this.nextWeight,
    required this.nextStallCount,
    required this.deload,
  });
}

/// Auto-regulación por doble progresión + deload.
/// - Todas las series al tope del rango (>= repHigh) => sube [increment].
/// - Dentro del rango (sin tope) => mantiene peso (busca más reps).
/// - Alguna serie por debajo de [repLow] => estancamiento +1; al alcanzar
///   [deloadThreshold] => deload (-10%) y resetea.
ProgressionResult decideProgression({
  required int repLow,
  required int repHigh,
  required double currentWeight,
  required List<int> repsPerSet,
  required int targetSets,
  required double increment,
  required int stallCount,
  int deloadThreshold = 3,
}) {
  final completedAll = repsPerSet.length >= targetSets &&
      repsPerSet.every((r) => r >= repHigh);
  if (completedAll) {
    return ProgressionResult(
      nextWeight: currentWeight + increment,
      nextStallCount: 0,
      deload: false,
    );
  }

  final failedLow = repsPerSet.any((r) => r < repLow);
  if (failedLow) {
    final newStall = stallCount + 1;
    if (newStall >= deloadThreshold) {
      return ProgressionResult(
        nextWeight: currentWeight * 0.9,
        nextStallCount: 0,
        deload: true,
      );
    }
    return ProgressionResult(
      nextWeight: currentWeight,
      nextStallCount: newStall,
      deload: false,
    );
  }

  // Dentro del rango pero sin llegar al tope: doble progresión (más reps).
  return ProgressionResult(
    nextWeight: currentWeight,
    nextStallCount: stallCount,
    deload: false,
  );
}
