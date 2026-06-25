import '../models/enums.dart';

/// Sube una división; `null` si ya está en la cima (leyenda).
Division? promote(Division d) =>
    d == Division.legend ? null : Division.values[d.index + 1];

/// Baja una división; `null` si ya está en el suelo (bronce).
Division? relegate(Division d) =>
    d == Division.bronze ? null : Division.values[d.index - 1];

/// Identificador absoluto de la semana (bloques de 7 días desde epoch, UTC).
/// Estable dentro de la semana y reproducible (sirve de semilla de la cohorte).
int weekIdFor(DateTime dt) {
  final days = dt.toUtc().difference(DateTime.utc(1970)).inDays;
  return days ~/ 7;
}
