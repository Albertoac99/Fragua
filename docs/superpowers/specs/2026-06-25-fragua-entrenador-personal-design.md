# Diseño — Fragua: entrenador personal (clon 0 € estilo Liftoff/Freeletics)

- **Fecha**: 2026-06-25
- **Estado**: aprobado para implementación
- **Autor**: Alberto Aranda Castro (con Claude)
- **Nombre de trabajo**: **Fragua** (tentativo, cambiable)
- **Origen**: idea #11 del catálogo de clones 0 € (`~/.claude/plans/proponme-ideas-de-aplicaciones-linear-sundae.md`), "Clon de Freeletics/Nike Training Club — entrenador personal" ⭐.

---

## 1. Contexto y objetivo

App de **entrenamiento personal** para que Alberto se ponga más fuerte, con todas las funciones "pro" de las apps típicas (Liftoff, Freeletics, Strong, Hevy) **sin pagar suscripción**. Estética limpia y gamificada estilo **Liftoff/Duolingo**, con **sistema de ligas** para motivar el progreso.

Misma filosofía que Gambito y Legajo:

- **Flutter + Android**, distribución por **sideload** (APK compilado en GitHub Actions, sin Play Store).
- **Sin backend, sin suscripción, offline-first, 0 €.**
- Motores/datos **open source** corriendo en el propio móvil.
- **Uso estrictamente personal**: la app nunca se publica ni se comparte. Esto simplifica la licencia de los recursos multimedia (ver §5).
- Máximo **reuso de Gambito**: BD SQLite pre-construida (estilo `puzzles.db`), banco de voz edge-tts "Álvaro", Riverpod, lógica de "coach por reglas", separación `core/` sin Flutter.

**Requisito explícito**: **bajo consumo de almacenamiento** en el móvil.

---

## 2. Decisiones cerradas (brainstorming 2026-06-25)

| Tema | Decisión |
|------|----------|
| Enfoque de entrenamiento | **Híbrido adaptativo, ambas modalidades en v1**: fuerza en gimnasio + guiados (HIIT/peso corporal). El coach **mezcla** ambas según objetivo/equipo del usuario. |
| Creación de planes | **El coach los genera y el usuario puede editarlos.** |
| Progresión | **Auto-regulada por rendimiento** (doble progresión + RIR/RPE + deloads en fuerza; reps/tiempo/densidad + escalera de variantes en guiado). |
| Ligas | **En solitario con rivales simulados (bots)**: divisiones bronce→leyenda, cohorte semanal, ascensos/descensos. Offline, 0 €. |
| Demostración de ejercicios | **GIFs animados reales** (set abierto), descarga bajo demanda + caché. 0 € por ser uso personal. |
| Coach de voz | **Sí, completo** (banco edge-tts "Álvaro": cuenta atrás de descansos, anuncios, ánimos y **cadencia de los guiados**). |
| Seguimiento | **Todo**: récords/gráficas de fuerza, peso corporal, medidas corporales, fotos de progreso. |
| Notificaciones | **Locales** (sin servidor): recordatorio de entreno configurable, "racha en peligro", fin de descanso. |
| Coste | **0 €.** El pack de GIFs de pago y la cuenta Play ($25) solo aplicarían si algún día se publicara — descartado. |

---

## 3. Alcance v1 (ambas modalidades) y mejoras futuras

La v1 incluye **las dos modalidades** y el coach las combina:

- **Fuerza** (series × reps × peso): registro manual con sobrecarga progresiva y auto-regulación.
- **Guiado** (circuitos / HIIT / calistenia): la app **dirige** el entreno por intervalos con cadencia por voz; progresión por reps/tiempo/densidad y escalera de variantes.

Ambas comparten toda la infraestructura: coach, progresión, voz, ligas, seguimiento y notificaciones. El coach decide la mezcla semanal de días de fuerza y días guiados según objetivo y equipo (§7.2).

**Mejoras futuras (post-v1, no bloqueantes)**: sincronización con Google Fit / Health Connect, calculadora de discos por barra, modo oscuro, más voces/idiomas, más escaleras de variantes guiadas, exportar/compartir progreso.

---

## 4. Stack técnico

- **Lenguaje/UI**: Flutter (Dart), objetivo Android.
- **Estado**: Riverpod.
- **Persistencia**: drift (SQLite). BD de ejercicios **pre-construida como asset** (estilo `puzzles.db` de Gambito).
- **Gráficas**: fl_chart.
- **Notificaciones**: flutter_local_notifications + timezone (100 % locales, sin FCM).
- **Audio/voz**: just_audio (reproducción de clips edge-tts, con ducking de la música del usuario).
- **Descarga/caché de GIFs**: cliente HTTP + caché en almacenamiento privado de la app (gestión propia o `flutter_cache_manager`).
- **Build**: GitHub Actions (`build-android.yml`) → APK como artifact para sideload. Mismo patrón que Gambito/Legajo.

---

## 5. El "Stockfish" del proyecto: datos y motores abiertos

### 5.1 Base de ejercicios (columna estructurada)
- **free-exercise-db** (yuhonas, **dominio público / Unlicense**): ~800 ejercicios con nombre, categoría, `force`, `level`, `mechanic`, equipo, músculos primarios/secundarios, instrucciones e imágenes inicio/fin. Es la fuente **estructurada y canónica**. Su campo `level` (beginner/intermediate/expert) ayuda a sembrar las escaleras de variantes (§5.4).

### 5.2 GIFs animados (capa visual)
- Set abierto descargable en bloque, p. ej. **FitnessDB/exercise-animation-dataset** (~1.500 ejercicios con GIF) o **ExerciseDB API v1 (open source)** (~1.300). Se **mapean por nombre** sobre la base estructurada de free-exercise-db.
- **Estrategia de almacenamiento** (requisito de bajo consumo): el APK base **no** incluye los GIFs. Se descargan **bajo demanda con wifi** (o "pre-descargar todo" desde ajustes) y se **cachean** en almacenamiento privado; opción de **vaciar caché**.
- **Cadena de fallback** si falta un GIF: imagen estática (free-exercise-db) → solo texto/instrucciones. La app **siempre** funciona aunque no haya red.
- **Licencia**: al ser **uso personal sin redistribución**, las restricciones "no comercial / no redistribuir" de estos sets no aplican en la práctica. Se documenta la fuente concreta elegida al integrarla (M5).

### 5.3 Banco de voz "Álvaro"
- Clips pre-generados con **edge-tts** (patrón Gambito), bundleados en `assets/voice/`: números para cuenta atrás de descanso/trabajo, "última serie", "siguiente ejercicio", "ronda X de Y", "trabajo"/"descanso", ánimos y avisos. Pipeline `tools/build_voice_bank.py` casi calcado de Gambito.

### 5.4 Escaleras de variantes (peso corporal)
- Para el modo guiado/calistenia, cada movimiento clave pertenece a un `variation_group` ordenado por dificultad (p. ej. flexión: pared → inclinada → rodillas → completa → diamante → declinada). Se siembran con el `level` de free-exercise-db y se **curan a mano** los grupos principales en el pipeline de build. Permiten progresar subiendo de variante (§7.3).

---

## 6. Arquitectura de carpetas

Separación clave (igual que Gambito/Legajo): **`core/` no importa Flutter** → lógica pura 100 % testeable; la UI solo orquesta.

```
fragua/
  CLAUDE.md                      # documento maestro del proyecto
  STRATEGY.md                    # filosofía/decisiones (opcional, estilo Gambito)
  pubspec.yaml
  assets/
    exercise_db.sqlite           # BD pre-construida (metadata + refs de imagen + variantes)
    voice/                       # banco edge-tts "Álvaro"
    images/                      # miniaturas estáticas mínimas (fallback)
  lib/
    main.dart
    core/                        # SIN Flutter → testeable
      models/                    # UserProfile, Exercise, Plan, PlanDay, PlanExercise,
                                 #   Session, SetLog, BodyMetric, ProgressPhoto,
                                 #   LeagueState, LeagueBot, Achievement, XpEntry
      coach/                     # generación del plan (mezcla fuerza/guiado) según perfil+equipo
      progression/              # fuerza (doble prog./RIR/deload) + guiado (reps/tiempo/variante)
      session/                   # motores de ejecución: fuerza (series/descansos) y guiado (intervalos)
      leagues/                   # XP, divisiones, bots simulados (seeded), asc/desc
      db/                        # drift (esquema, DAOs, migraciones)
    features/                    # UI por feature (Riverpod)
      onboarding/  home/  plan/  workout/  stats/  leagues/  settings/
    services/                    # voz, notificaciones, descarga/caché de GIFs
    ui/                          # tema limpio estilo Duolingo/Liftoff, widgets compartidos
  tools/
    build_exercise_db.py         # free-exercise-db (+mapping GIF +variantes) → exercise_db.sqlite
    build_voice_bank.py          # edge-tts → assets/voice (reuso Gambito)
  test/                          # tests del core (coach, progression, session, leagues)
  .github/workflows/build-android.yml
```

---

## 7. Componentes / módulos

### 7.1 Onboarding (cuestionario inicial)
Recoge lo necesario para que el coach diseñe el mejor plan:
- **Datos físicos**: género, fecha de nacimiento (edad), altura, peso.
- **Objetivo**: perder grasa · hipertrofia (ganar músculo) · fuerza máxima · forma física general · resistencia.
- **Nivel**: principiante · intermedio · avanzado (o auto-estimado con 2-3 preguntas).
- **Disponibilidad**: días/semana + duración de sesión.
- **Equipo disponible** (multi-selección): peso corporal, mancuernas, barra + discos + rack, máquinas / gym completo, kettlebell, bandas elásticas, barra de dominadas, banco…
- **Limitaciones/lesiones** (opcional): rodilla, hombro, lumbar… → excluye ejercicios contraindicados.
- **Preferencias** (opcional): ejercicios favoritos/a evitar; afinidad por fuerza vs guiados.

Salida: `UserProfile` persistido → alimenta al coach. Editable después en ajustes.

### 7.2 Motor del coach (generación de plan)
Determinista, por reglas, offline:
0. **Modalidad según objetivo/equipo**: el coach decide la mezcla semanal de días de **fuerza** y días **guiados**:
   - fuerza máxima / hipertrofia → mayoría fuerza (+0-1 día guiado de conditioning opcional);
   - pérdida de grasa → fuerza para mantener músculo + 1-2 días guiados (HIIT/circuitos);
   - resistencia / forma general → mezcla equilibrada;
   - solo peso corporal → predominan guiados/calistenia con progresión por variante.
1. **Split** de los días de fuerza según días/semana: 1-2 → Full Body · 3 → Full Body / PPL reducido · 4 → Upper/Lower · 5-6 → PPL.
2. **Esquema de reps/descansos** según objetivo: fuerza 3-6 reps (desc. 2-4 min) · hipertrofia 6-12 (60-120 s) · resistencia 12-20 (30-60 s) · forma general 8-12.
3. **Volumen** según nivel (principiante: menos series, foco en compuestos; avanzado: más volumen y aislamiento).
4. **Selección de ejercicios**: por cada grupo muscular objetivo del día, filtra el pool de free-exercise-db por **equipo disponible** y **lesiones**, prioriza compuestos (`mechanic = compound`) y completa con accesorios.
5. **Días guiados**: monta circuitos/intervalos (formato, rondas, trabajo/descanso) con ejercicios acordes al equipo y nivel, usando las escaleras de variantes (§5.4).
6. **Sustitución**: si falta material o un ejercicio molesta, ofrece alternativa con el mismo músculo primario y equipo compatible.
7. **Editable**: el usuario puede cambiar ejercicios, series, días y modalidad.

Garantía: con equipo mínimo (solo peso corporal) **siempre** produce un plan válido (predominio de guiados/calistenia).

### 7.3 Motor de progresión (auto-regulación)

**Fuerza** — cada serie registra peso, reps y (opcional) **RIR/RPE**. Cada `PlanExercise` tiene rango objetivo `[rep_low, rep_high]` y peso de trabajo actual. Tras cada sesión, por ejercicio:
- Todas las series llegan a `rep_high` con RIR ≥ 1 → **subir peso** (+2,5 kg compuesto, +1–2,5 kg aislamiento).
- Dentro del rango pero sin tope → **mantener peso**, buscar más reps (doble progresión).
- Por debajo de `rep_low` en 2 sesiones seguidas → **bajar peso** (~10 %).
- **Estancamiento** (sin progreso en N sesiones, p. ej. 3) → **deload** automático (−40/50 % una semana) y reanudar.

**Guiado / peso corporal** — progresión por:
- **(a) reps/tiempo**: subir reps objetivo o segundos de trabajo;
- **(b) densidad**: reducir descanso o añadir rondas;
- **(c) escalera de variantes** (§5.4): al dominar el objetivo con buena ejecución, subir a la variante más difícil del `variation_group`.

### 7.4 Ejecución de la sesión (fuerza y guiado)
Dos modos según el tipo de día generado por el coach (motor en `core/session/`):
- **Sesión de fuerza**: lista de ejercicios; por cada serie el usuario registra peso/reps (+RIR opcional); temporizador de descanso entre series con **voz** (cuenta atrás); muestra **GIF** del ejercicio y "siguiente". Al cerrar, dispara la progresión (§7.3).
- **Sesión guiada**: la app **dirige** el entreno por intervalos. Formatos: **intervalos** (trabajo/descanso), **circuito** (secuencia × rondas) y **AMRAP** (máximas rondas en X min). La **voz** marca la cadencia: anuncia ejercicio, cuenta atrás de trabajo/descanso, "ronda 2 de 4", ánimos y "media vuelta". Pantalla con temporizador grande, GIF actual, próximo ejercicio y anillo de progreso. Registro por bloque (rondas/reps/tiempo completados).

Ambos modos alimentan por igual la XP/rachas/ligas (§7.5) y el seguimiento (§7.7).

### 7.5 Sistema de ligas (gamificación estilo Duolingo, offline)
- **XP** por: completar entreno (base) · series/bloques registrados · bonus de volumen/intensidad · **PR** (+bonus) · racha · completar el plan semanal.
- **Divisiones**: Bronce → Plata → Oro → Platino → Diamante → Leyenda (6).
- **Cohorte semanal**: ~20 **rivales simulados** (bots) con nombre y arquetipo (constante / esporádico / principiante / "grinder"); su XP semanal se genera con una **distribución sembrada (seeded)** → leaderboard estable durante la semana y **reproducible** (testeable).
- **Fin de semana**: top ~5 ascienden, cola ~5 descienden (con suelo en Bronce y techo en Leyenda).
- **Rachas** (diaria/semanal) + **logros/medallas** (primer PR, 10/50/100 entrenos, constancia…).

### 7.6 Coach de voz (Álvaro)
- **Fuerza**: cuenta atrás de descansos (3-2-1), "última serie", "siguiente: …", ánimos.
- **Guiado**: cadencia completa — "trabajo"/"descanso", segundos, "ronda X de Y", "media vuelta", "última ronda", ánimos.
- just_audio con ducking de la música del usuario. Si falla el audio, los temporizadores y la vibración siguen funcionando.

### 7.7 Seguimiento / progreso
- **Fuerza**: PR por ejercicio, 1RM estimado (Epley), volumen por grupo muscular, evolución temporal.
- **Peso corporal**: registro + gráfica.
- **Medidas corporales**: cintura, brazo, pecho, pierna, etc.
- **Fotos de progreso**: comparativa antes/después; almacenadas en **almacenamiento privado** de la app, borrables; aviso de que consumen espacio (off por defecto).
- Pantalla de estadísticas con fl_chart.

### 7.8 Notificaciones (locales)
- **Recordatorio de entreno** configurable (días + hora).
- **"Racha en peligro"** estilo Duolingo.
- **Fin de descanso** durante la sesión (si la app está en segundo plano).
- Gestión del permiso `POST_NOTIFICATIONS` (Android 13+) con degradado elegante si se deniega.

### 7.9 Pipeline de multimedia y caché
- `build_exercise_db.py`: free-exercise-db JSON → normaliza → `exercise_db.sqlite` (metadata + modalidad + escaleras de variantes + refs de imagen estática + clave de mapeo a GIF).
- App: primera ejecución ofrece **pre-descarga** del set de GIFs por wifi; si no, **lazy fetch** por ejercicio + caché. Ajuste para **vaciar caché**. Fallback a estática/texto.

---

## 8. Modelo de datos (drift / SQLite)

- `user_profile` (sexo, fecha_nac, altura_cm, peso_kg, objetivo, nivel, dias_semana, minutos_sesion, …)
- `profile_equipment` (profile_id, equipo) — N
- `profile_limitation` (profile_id, region) — N
- `exercise` (id, nombre, categoria, force, level, mechanic, equipo, musculos_primarios, musculos_secundarios, instrucciones, imagen_estatica, gif_key, **modalidad** [fuerza/guiado/ambas], **variation_group**, **variation_rank**) — *pre-construida*
- `plan` (id, profile_id, nombre, split, creado_en, activo)
- `plan_day` (id, plan_id, indice, nombre, **tipo** [fuerza/guiado], **formato** [series/intervalos/circuito/amrap], **rondas**, **trabajo_s**, **descanso_s**)
- `plan_exercise` (id, plan_day_id, exercise_id, orden, series_objetivo, rep_low, rep_high, **peso_actual** (nullable), **trabajo_s** (nullable), descanso_s)
- `session` (id, plan_day_id, fecha, inicio, fin, estado)
- `set_log` (id, session_id, plan_exercise_id, indice_serie, **peso** (nullable), reps, **duracion_s** (nullable), rir, completada)
- `body_metric` (id, profile_id, fecha, tipo, valor)
- `progress_photo` (id, profile_id, fecha, ruta, pose)
- `xp_entry` (id, profile_id, fecha, fuente, cantidad)
- `league_state` (profile_id, division_actual, week_id, xp_semana)
- `league_bot` (week_id, bot_id, nombre, arquetipo, xp_semana) — generada (seeded)
- `achievement` (id, profile_id, tipo, desbloqueado_en)
- `streak` (profile_id, actual, ultima_fecha_activa, record)
- `settings` (notificaciones, unidades kg/lb, voz on/off, …)

---

## 9. Flujo de datos (camino feliz)

1. **Onboarding** → `UserProfile` (+ equipo, limitaciones) en DB.
2. **Coach** genera `Plan` con días de **fuerza** y/o **guiado** (`PlanDay` + `PlanExercise`).
3. Usuario abre **Home** → siguiente entreno del plan.
4. **Sesión** (§7.4):
   - *fuerza*: registra `SetLog` por serie, descanso + voz, GIF;
   - *guiado*: la app dirige intervalos/rondas con voz; registra bloques completados.
5. Al cerrar: **progresión** evalúa y ajusta (peso/rango en fuerza; reps/tiempo/variante en guiado; deload si procede).
6. Se generan **XP** → `league_state.xp_semana`; actualiza racha y logros.
7. **Stats** y **Leagues** leen los datos para gráficas y leaderboard.
8. **Notificaciones** programadas según ajustes.

---

## 10. Estética / UX

Limpia, redondeada, colores vivos por categoría/grupo muscular, tarjetas, progreso circular, medallas de liga; sensación **Duolingo/Liftoff**. Se podrá apoyar en la skill `frontend-design` durante la implementación. Modo claro (oscuro opcional más adelante).

---

## 11. Almacenamiento (requisito: bajo)

- **APK base ligero**: BD (texto/metadata) + banco de voz comprimido + miniaturas estáticas mínimas → objetivo "pocas decenas de MB".
- **GIFs**: fuera del APK, descarga bajo demanda + caché (gestionable y borrable).
- **Fotos de progreso**: del usuario, controlables/borrables.

---

## 12. Manejo de errores

- **Offline-first**: todo el núcleo funciona sin red; solo la descarga de GIFs la necesita → fallback estática/texto + reintento.
- **Migraciones** de esquema con drift (versionado).
- **Permiso de notificaciones** (Android 13+): solicitud + degradado si se deniega.
- **Audio**: fallo de voz → temporizadores y vibración siguen.
- **Coach**: siempre genera plan válido aun con equipo mínimo (fallback peso corporal/guiado).
- **Multimedia ausente**: cadena GIF → estática → texto.
- **Almacenamiento**: aviso al activar fotos; permitir borrar caché y fotos.

---

## 13. Testing

- `core/` en Dart puro (sin Flutter) → **tests unitarios**:
  - **Coach**: dados perfiles+equipo, valida la mezcla de modalidades, splits, que la selección respeta equipo/lesiones, y los esquemas de reps/intervalos por objetivo.
  - **Progresión**: reglas deterministas de fuerza (subir/mantener/bajar/deload) y de guiado (reps/tiempo/variante) ante secuencias de registro.
  - **Sesión**: motor de intervalos/circuitos/AMRAP (transiciones, rondas, conteos).
  - **Ligas**: bots reproducibles por semilla; lógica de XP y ascensos/descensos.
- **Fixtures**: perfiles de ejemplo + subconjunto de la BD de ejercicios.
- Tests de widget/integración mínimos (estilo Gambito).
- **Prueba real final**: APK del workflow sideloadeado en el móvil físico de Alberto (equivalente al test real de Gambito).

---

## 14. Milestones

- **M0 — Esqueleto**: repo, scaffold Flutter, drift, modelos `core`, `build_exercise_db.py` con free-exercise-db (modalidad + escaleras de variantes) → `exercise_db.sqlite`, tests core mínimos. (Push a GitHub con tu OK.)
- **M1 — Onboarding + perfil**: cuestionario completo → `UserProfile`.
- **M2 — Coach (generación)**: motor que genera el plan (mezcla fuerza/guiado) desde el perfil + equipo; pantalla de plan; edición básica.
- **M3 — Sesión de fuerza + auto-regulación + voz**: ejecutar entreno, registrar series, temporizador de descanso, voz Álvaro, doble progresión/deload.
- **M4 — Modo guiado**: motor de intervalos/circuitos/AMRAP, cadencia por voz, progresión por reps/tiempo/variante.
- **M5 — Animaciones**: integración del set de GIFs + descarga bajo demanda/caché + fallback.
- **M6 — Ligas + gamificación**: XP, divisiones, cohorte de bots, rachas, logros.
- **M7 — Seguimiento**: gráficas de fuerza, peso, medidas, fotos.
- **M8 — Notificaciones + ajustes**: recordatorios configurables, "racha en peligro".
- **M9 — Empaquetado**: workflow GitHub Actions → APK; sideload y pruebas en el móvil; ajustes; tag `v1.0`.
- **Mejoras futuras (post-v1)**: sync Google Fit/Health Connect, calculadora de discos, modo oscuro, más voces/idiomas, más variantes guiadas, exportar progreso.

---

## 15. Opciones de pago (documentado)

- **Uso personal → 0 €** en todo, incluidas las animaciones.
- **Pack de GIFs profesionales (pago único)** y **cuenta Google Play ($25, pago único)**: **descartados** porque no se va a publicar. Solo se reconsiderarían si la app se distribuyera públicamente.

---

## 16. Riesgos y cuestiones abiertas

- **Mapeo nombre↔GIF** entre datasets puede dejar ejercicios sin animación → mitigado por la cadena de fallback (estática/texto) y por permitir asignación manual.
- **Calidad/cobertura** de los GIFs del set abierto: se valida la fuente concreta en M5.
- **Curación de las escaleras de variantes** de peso corporal: `level` ayuda, pero los `variation_group` clave hay que curarlos a mano.
- **Equilibrio entre modalidades** en el coach: afinar cuántos días de fuerza vs guiado por objetivo para que el plan sea coherente.
- **Realismo de los bots** de liga: ajustar distribuciones para que motive sin frustrar.
- **Nombre definitivo** de la app (Fragua es tentativo).
