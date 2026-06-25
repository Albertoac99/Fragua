# Diseño — Fragua: entrenador personal (clon 0 € estilo Liftoff/Freeletics)

- **Fecha**: 2026-06-25
- **Estado**: aprobado para implementación (pendiente de revisión final del spec)
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
| Enfoque de entrenamiento | **Híbrido adaptativo**: fuerza en gimnasio + guiados peso corporal/HIIT, usando uno u otro según las necesidades del usuario detectadas en el onboarding. |
| Creación de planes | **El coach los genera y el usuario puede editarlos.** |
| Progresión | **Auto-regulada por rendimiento** (doble progresión + RIR/RPE + deloads automáticos). |
| Ligas | **En solitario con rivales simulados (bots)**: divisiones bronce→leyenda, cohorte semanal, ascensos/descensos. Offline, 0 €. |
| Demostración de ejercicios | **GIFs animados reales** (set abierto), descarga bajo demanda + caché. 0 € por ser uso personal. |
| Coach de voz | **Sí, completo** (banco edge-tts "Álvaro": cuenta atrás de descansos, anuncios, ánimos, cadencia). |
| Seguimiento | **Todo**: récords/gráficas de fuerza, peso corporal, medidas corporales, fotos de progreso. |
| Notificaciones | **Locales** (sin servidor): recordatorio de entreno configurable, "racha en peligro", fin de descanso. |
| Coste | **0 €.** El pack de GIFs de pago y la cuenta Play ($25) solo aplicarían si algún día se publicara — descartado. |

---

## 3. Alcance: v1 vs v2

Para que la v1 sea abarcable, se construye **primero el núcleo de fuerza completo** (lo más valioso y lo que más reusa Gambito). El **modo guiado HIIT/peso corporal** se engancha encima como **v2**, reutilizando el mismo coach, voz, ligas y seguimiento.

- **v1 (este spec)**: onboarding → coach genera plan de fuerza → sesión con logging + temporizador + voz → auto-regulación → animaciones → ligas → seguimiento → notificaciones → APK.
- **v2 (futuro)**: rutinas guiadas cronometradas (HIIT/calistenia) con cadencia por voz, circuitos y AMRAP; el coach decide cuándo proponer trabajo guiado según objetivo/equipo.

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
- **free-exercise-db** (yuhonas, **dominio público / Unlicense**): ~800 ejercicios con nombre, categoría, `force`, `level`, `mechanic`, equipo, músculos primarios/secundarios, instrucciones e imágenes inicio/fin. Es la fuente **estructurada y canónica**.

### 5.2 GIFs animados (capa visual)
- Set abierto descargable en bloque, p. ej. **FitnessDB/exercise-animation-dataset** (~1.500 ejercicios con GIF) o **ExerciseDB API v1 (open source)** (~1.300). Se **mapean por nombre** sobre la base estructurada de free-exercise-db.
- **Estrategia de almacenamiento** (requisito de bajo consumo): el APK base **no** incluye los GIFs. Se descargan **bajo demanda con wifi** (o "pre-descargar todo" desde ajustes) y se **cachean** en almacenamiento privado; opción de **vaciar caché**.
- **Cadena de fallback** si falta un GIF: imagen estática (free-exercise-db) → solo texto/instrucciones. La app **siempre** funciona aunque no haya red.
- **Licencia**: al ser **uso personal sin redistribución**, las restricciones "no comercial / no redistribuir" de estos sets no aplican en la práctica. Se documenta la fuente concreta elegida al integrarla (M4).

### 5.3 Banco de voz "Álvaro"
- Clips pre-generados con **edge-tts** (patrón Gambito), bundleados en `assets/voice/`: números para cuenta atrás de descanso, "última serie", "siguiente ejercicio", ánimos, avisos. Pipeline `tools/build_voice_bank.py` casi calcado de Gambito.

---

## 6. Arquitectura de carpetas

Separación clave (igual que Gambito/Legajo): **`core/` no importa Flutter** → lógica pura 100 % testeable; la UI solo orquesta.

```
fragua/
  CLAUDE.md                      # documento maestro del proyecto
  STRATEGY.md                    # filosofía/decisiones (opcional, estilo Gambito)
  pubspec.yaml
  assets/
    exercise_db.sqlite           # BD pre-construida (metadata + refs de imagen)
    voice/                       # banco edge-tts "Álvaro"
    images/                      # miniaturas estáticas mínimas (fallback)
  lib/
    main.dart
    core/                        # SIN Flutter → testeable
      models/                    # UserProfile, Exercise, Plan, PlanDay, PlanExercise,
                                 #   Session, SetLog, BodyMetric, ProgressPhoto,
                                 #   LeagueState, LeagueBot, Achievement, XpEntry
      coach/                     # generación del plan a partir del perfil + equipo
      progression/              # doble progresión, RIR, detección de estancamiento, deload
      leagues/                   # XP, divisiones, bots simulados (seeded), asc/desc
      db/                        # drift (esquema, DAOs, migraciones)
    features/                    # UI por feature (Riverpod)
      onboarding/  home/  plan/  workout/  stats/  leagues/  settings/
    services/                    # voz, notificaciones, descarga/caché de GIFs
    ui/                          # tema limpio estilo Duolingo/Liftoff, widgets compartidos
  tools/
    build_exercise_db.py         # free-exercise-db (+mapping GIF) → exercise_db.sqlite
    build_voice_bank.py          # edge-tts → assets/voice (reuso Gambito)
  test/                          # tests del core (coach, progression, leagues)
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
- **Preferencias** (opcional): ejercicios favoritos/a evitar.

Salida: `UserProfile` persistido → alimenta al coach. Editable después en ajustes.

### 7.2 Motor del coach (generación de plan)
Determinista, por reglas, offline:
1. **Split** según días/semana: 1-2 → Full Body · 3 → Full Body / PPL reducido · 4 → Upper/Lower · 5-6 → PPL.
2. **Esquema de reps/descansos** según objetivo: fuerza 3-6 reps (desc. 2-4 min) · hipertrofia 6-12 (60-120 s) · resistencia 12-20 (30-60 s) · forma general 8-12 · pérdida de grasa = hipertrofia con mayor densidad.
3. **Volumen** según nivel (principiante: menos series, foco en compuestos; avanzado: más volumen y aislamiento).
4. **Selección de ejercicios**: por cada grupo muscular objetivo del día, filtra el pool de free-exercise-db por **equipo disponible** y **lesiones**, prioriza compuestos (`mechanic = compound`) y completa con accesorios.
5. **Sustitución**: si falta material o un ejercicio molesta, ofrece alternativa con el mismo músculo primario y equipo compatible.
6. **Editable**: el usuario puede cambiar ejercicios, series, días.

Garantía: con equipo mínimo (solo peso corporal) **siempre** produce un plan válido.

### 7.3 Motor de progresión (auto-regulación)
Cada serie registra: peso, reps y (opcional) **RIR/RPE**. Cada `PlanExercise` tiene rango objetivo `[rep_low, rep_high]` y peso de trabajo actual.

Reglas tras cada sesión, por ejercicio:
- Todas las series llegan a `rep_high` con RIR ≥ 1 → **subir peso** (incremento por tipo: +2,5 kg compuesto, +1–2,5 kg aislamiento; en peso corporal → subir reps y luego progresar a variante más difícil).
- Dentro del rango pero sin llegar al tope → **mantener peso**, buscar más reps (doble progresión).
- Por debajo de `rep_low` en 2 sesiones seguidas → **bajar peso** (~10 %).
- **Estancamiento**: sin progreso en N sesiones (p. ej. 3) en un ejercicio → **deload** automático (volumen/intensidad −40/50 % una semana) y reanudar.
- Ajuste de volumen semanal según constancia/fatiga auto-reportada (opcional).

### 7.4 Sistema de ligas (gamificación estilo Duolingo, offline)
- **XP** por: completar entreno (base) · series registradas · bonus de volumen · **PR** (+bonus) · racha · completar el plan semanal.
- **Divisiones**: Bronce → Plata → Oro → Platino → Diamante → Leyenda (6).
- **Cohorte semanal**: ~20 **rivales simulados** (bots) con nombre y arquetipo (constante / esporádico / principiante / "grinder"); su XP semanal se genera con una **distribución sembrada (seeded)** → leaderboard estable durante la semana y **reproducible** (testeable).
- **Fin de semana**: top ~5 ascienden, cola ~5 descienden (con suelo en Bronce y techo en Leyenda).
- **Rachas** (diaria/semanal) + **logros/medallas** (primer PR, 10/50/100 entrenos, constancia…).

### 7.5 Coach de voz (Álvaro)
- Cuenta atrás de descansos (3-2-1), "última serie", "siguiente: …", ánimos; en v2, cadencia para guiados.
- just_audio con ducking de la música del usuario. Si falla el audio, los temporizadores siguen funcionando.

### 7.6 Seguimiento / progreso
- **Fuerza**: PR por ejercicio, 1RM estimado (Epley), volumen por grupo muscular, evolución temporal.
- **Peso corporal**: registro + gráfica.
- **Medidas corporales**: cintura, brazo, pecho, pierna, etc.
- **Fotos de progreso**: comparativa antes/después; almacenadas en **almacenamiento privado** de la app, borrables; aviso de que consumen espacio (off por defecto).
- Pantalla de estadísticas con fl_chart.

### 7.7 Notificaciones (locales)
- **Recordatorio de entreno** configurable (días + hora).
- **"Racha en peligro"** estilo Duolingo.
- **Fin de descanso** durante la sesión (si la app está en segundo plano).
- Gestión del permiso `POST_NOTIFICATIONS` (Android 13+) con degradado elegante si se deniega.

### 7.8 Pipeline de multimedia y caché
- `build_exercise_db.py`: free-exercise-db JSON → normaliza → `exercise_db.sqlite` (metadata + refs de imagen estática + clave de mapeo a GIF).
- App: primera ejecución ofrece **pre-descarga** del set de GIFs por wifi; si no, **lazy fetch** por ejercicio + caché. Ajuste para **vaciar caché**. Fallback a estática/texto.

---

## 8. Modelo de datos (drift / SQLite)

- `user_profile` (sexo, fecha_nac, altura_cm, peso_kg, objetivo, nivel, dias_semana, minutos_sesion, …)
- `profile_equipment` (profile_id, equipo) — N
- `profile_limitation` (profile_id, region) — N
- `exercise` (id, nombre, categoria, force, level, mechanic, equipo, musculos_primarios, musculos_secundarios, instrucciones, imagen_estatica, gif_key) — *pre-construida*
- `plan` (id, profile_id, nombre, split, creado_en, activo)
- `plan_day` (id, plan_id, indice, nombre p. ej. "Push")
- `plan_exercise` (id, plan_day_id, exercise_id, orden, series_objetivo, rep_low, rep_high, peso_actual, descanso_s)
- `session` (id, plan_day_id, fecha, inicio, fin, estado)
- `set_log` (id, session_id, plan_exercise_id, indice_serie, peso, reps, rir, completada)
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
2. **Coach** genera `Plan` + `PlanDay` + `PlanExercise` desde el perfil.
3. Usuario abre **Home** → siguiente entreno del plan.
4. **Sesión**: ejecuta ejercicios, registra `SetLog` por serie, temporizador de descanso + **voz**, muestra **GIF**.
5. Al cerrar sesión: **progresión** evalúa cada ejercicio y ajusta `peso_actual`/rango (o marca deload).
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
- **Coach**: siempre genera plan válido aun con equipo mínimo (fallback peso corporal).
- **Multimedia ausente**: cadena GIF → estática → texto.
- **Almacenamiento**: aviso al activar fotos; permitir borrar caché y fotos.

---

## 13. Testing

- `core/` en Dart puro (sin Flutter) → **tests unitarios**:
  - **Coach**: dados perfiles+equipo, valida splits, que la selección respeta equipo/lesiones, y los esquemas de reps por objetivo.
  - **Progresión**: reglas deterministas (subir/mantener/bajar/deload) ante secuencias de `SetLog`.
  - **Ligas**: bots reproducibles por semilla; lógica de XP y ascensos/descensos.
- **Fixtures**: perfiles de ejemplo + subconjunto de la BD de ejercicios.
- Tests de widget/integración mínimos (estilo Gambito).
- **Prueba real final**: APK del workflow sideloadeado en el móvil físico de Alberto (equivalente al test real de Gambito).

---

## 14. Milestones

- **M0 — Esqueleto**: repo, scaffold Flutter, drift, modelos `core`, `build_exercise_db.py` con free-exercise-db → `exercise_db.sqlite`, tests core mínimos. (Push a GitHub con tu OK.)
- **M1 — Onboarding + perfil**: cuestionario completo → `UserProfile`.
- **M2 — Coach (generación)**: motor que genera el plan desde el perfil + equipo; pantalla de plan; edición básica.
- **M3 — Sesión + logging + auto-regulación + voz**: ejecutar entreno, registrar series, temporizador de descanso, voz Álvaro, reglas de doble progresión/deload.
- **M4 — Animaciones**: integración del set de GIFs + descarga bajo demanda/caché + fallback.
- **M5 — Ligas + gamificación**: XP, divisiones, cohorte de bots, rachas, logros.
- **M6 — Seguimiento**: gráficas de fuerza, peso, medidas, fotos.
- **M7 — Notificaciones + ajustes**: recordatorios configurables, "racha en peligro".
- **M8 — Empaquetado**: workflow GitHub Actions → APK; sideload y pruebas en el móvil; ajustes; tag `v1.0`.
- **v2 (futuro)**: modo guiado HIIT/peso corporal con cadencia por voz.

---

## 15. Opciones de pago (documentado)

- **Uso personal → 0 €** en todo, incluidas las animaciones.
- **Pack de GIFs profesionales (pago único)** y **cuenta Google Play ($25, pago único)**: **descartados** porque no se va a publicar. Solo se reconsiderarían si la app se distribuyera públicamente.

---

## 16. Riesgos y cuestiones abiertas

- **Mapeo nombre↔GIF** entre datasets puede dejar ejercicios sin animación → mitigado por la cadena de fallback (estática/texto) y por permitir asignación manual.
- **Calidad/cobertura** de los GIFs del set abierto: se valida la fuente concreta en M4.
- **Realismo de los bots** de liga: ajustar distribuciones para que motive sin frustrar.
- **Nombre definitivo** de la app (Fragua es tentativo).
