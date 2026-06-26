# Fragua M9 — Empaquetado: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Empaquetar Fragua para **sideload**: APK release **firmado con keystore propio** construido en **GitHub Actions**, CI de tests en cada push/PR, y publicación de un **Release** con el APK al taggear `v*` (entrega v1.0).

**Architecture:** Dos workflows: `ci.yml` corre `flutter analyze` + `flutter test` + `pytest` de `tools/` en cada push/PR (detección temprana de regresiones); `build-android.yml` corre los tests y construye el APK **solo** en tag `v*` o `workflow_dispatch`, restaurando el keystore release desde *secrets* y publicando un GitHub Release con el APK. La firma release vive tras un **degradado**: `android/app/build.gradle.kts` lee `key.properties` si existe (CI o local con keystore) y, en su ausencia (clones sin keystore), cae a la debug key para no romper `flutter run`. El keystore y sus credenciales **nunca** se versionan: viven como *secrets* en GitHub y como archivo local fuera del repo.

**Tech Stack:** GitHub Actions (`subosito/flutter-action@v2`, `actions/setup-python@v5`, `actions/upload-artifact@v4`, `softprops/action-gh-release`) · Gradle Kotlin DSL · `keytool` (JDK) · Flutter 3.44.1 · pytest.

## Global Constraints

- **Sideload sin Play Store** (spec §1, §14 M9): distribución por APK; nada de subir a stores.
- **0 €** (spec §15): solo herramientas gratuitas; GitHub Actions en runners públicos.
- **APK base ligero** (spec §11): los GIFs van **fuera** del APK (descarga bajo demanda, ya en M5); el empaquetado no los incluye.
- **Versión Flutter fijada** `3.44.1` (canal `stable`) en CI, igual que el entorno local, para builds reproducibles.
- **Reproducibilidad de la firma**: misma identidad de firma entre versiones → actualizar el APK in-place sin desinstalar (no perder el historial local del usuario).
- **Secretos fuera del repo**: `key.properties`, `*.jks`, `*.keystore` jamás se versionan (`.gitignore`).
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `android/app/build.gradle.kts` — (modificar) carga de `key.properties` + `signingConfigs.release` condicional; el buildType `release` firma con el keystore si existe, si no degrada a `debug`.
- `android/app/src/main/AndroidManifest.xml` — (modificar) `android:label` `fragua` → `Fragua`.
- `.gitignore` — (modificar) ignorar `key.properties`, `*.jks`, `*.keystore`.
- `.github/workflows/ci.yml` — (crear) tests en push/PR (job `flutter`: analyze+test; job `tools`: pytest).
- `.github/workflows/build-android.yml` — (crear) build del APK firmado + Release en tag `v*`/dispatch.
- `~/keys/fragua-release.jks` — (crear, **fuera del repo**) keystore release; su base64 + credenciales se cargan como *secrets* en GitHub.
- `README.md` — (modificar) instrucciones de build, firma, CI y sideload.

---

### Task 1: Firma release con keystore propio (degradado a debug) + nombre visible

**Files:**
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `.gitignore`

**Interfaces:**
- Produces: un `release` buildType que firma con `signingConfigs.getByName("release")` cuando existe `android/key.properties`, y con `debug` en su ausencia. `key.properties` admite las claves `storePassword`, `keyPassword`, `keyAlias`, `storeFile` (esta última resuelta por `file(...)` relativa a `android/app/`, o absoluta).

- [ ] **Step 1: Ignorar el keystore y sus credenciales**

En `.gitignore`, al final del archivo, añade:
```gitignore

# Firma release (M9): el keystore y sus credenciales NUNCA se versionan.
**/key.properties
**/*.jks
**/*.keystore
```

- [ ] **Step 2: Firma release condicional en build.gradle.kts**

Reemplaza el contenido completo de `android/app/build.gradle.kts` por:
```kotlin
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Carga `android/key.properties` si existe (no se versiona). En su ausencia
// (clones sin el keystore), el release degrada a la debug key para que
// `flutter run --release` siga funcionando en local sin fricción.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.aranda.fragua"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.aranda.fragua"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Keystore propio si está disponible; si no, debug key (degradado).
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
```

- [ ] **Step 3: Nombre visible de la app**

En `android/app/src/main/AndroidManifest.xml`, cambia el `android:label` de la `<application>`:
```xml
        android:label="Fragua"
```
(antes: `android:label="fragua"`).

- [ ] **Step 4: Verificar que el build degradado sigue compilando**

Sin `key.properties` presente, el release debe degradar a debug y compilar. Con JDK 21 (no hay 17 en el host; Gradle 9.1 soporta 21):
```bash
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 flutter build apk --release
```
Expected: `✓ Built build/app/outputs/flutter-apk/app-release.apk` (firmado con la debug key, porque aún no hay `key.properties`).

> Si el build local fallara por toolchain Android del host (no por nuestro cambio), no es bloqueante: el APK definitivo lo produce CI. Documentar el error y continuar; la firma real se valida en Task 5/CI.

- [ ] **Step 5: Commit**

```bash
git add android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml .gitignore
git commit -m "build(android): firma release con keystore propio (degradado a debug) + nombre Fragua

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Workflow CI — tests en cada push/PR

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `pubspec.yaml` (Flutter 3.44.1), `tools/requirements.txt` (`requests`, `pytest`), suite `test/` (118 tests) y `tools/test_build_exercise_db.py`.
- Produces: workflow `ci` con jobs `flutter` (analyze + test) y `tools` (pytest), disparado en push a `master`, en `pull_request` y por `workflow_dispatch`.

- [ ] **Step 1: Crear el workflow de CI**

Crea `.github/workflows/ci.yml`:
```yaml
name: ci

on:
  push:
    branches: [master]
  pull_request:
  workflow_dispatch:

jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.1
          channel: stable
          cache: true

      - name: Dependencias
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Tests
        run: flutter test

  tools:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Dependencias de tools
        run: pip install -r tools/requirements.txt

      - name: Pytest (tools)
        working-directory: tools
        run: python -m pytest -q
```

- [ ] **Step 2: Verificar localmente lo que el CI ejecutará**

Replica los comandos del CI en local (deben pasar antes de subir el workflow):
```bash
flutter analyze
flutter test
( cd tools && python -m pytest -q )
```
Expected: `No issues found!`, `All tests passed!` (118), y pytest verde (9 tests). Si no hay venv de tools con pytest, usar `tools/.venv/bin/python -m pytest -q` o crear el venv.

- [ ] **Step 3: Validar la sintaxis YAML del workflow**

```bash
python -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('ci.yml OK')"
```
Expected: `ci.yml OK`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: tests de flutter y tools en cada push/PR

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Workflow build-android — APK firmado + Release en tag

**Files:**
- Create: `.github/workflows/build-android.yml`

**Interfaces:**
- Consumes (secrets de GitHub, se configuran en Task 4): `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`. El layout de firma debe casar con Task 1: keystore en `android/app/fragua-release.jks`, `key.properties` en `android/key.properties` con `storeFile=fragua-release.jks`.
- Produces: workflow `build-android` (tag `v*` + `workflow_dispatch`) que sube el APK como artifact y, en tags, publica un Release con `Fragua-<tag>.apk`.

- [ ] **Step 1: Crear el workflow de build**

Crea `.github/workflows/build-android.yml`:
```yaml
name: build-android

on:
  push:
    tags: ["v*"]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.1
          channel: stable
          cache: true

      - name: Dependencias
        run: flutter pub get

      - name: Tests
        run: flutter test

      - name: Restaurar keystore release
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/fragua-release.jks

      - name: Generar key.properties
        env:
          STORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          cat > android/key.properties <<EOF
          storePassword=$STORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=fragua-release.jks
          EOF

      - name: Build APK release
        run: flutter build apk --release

      - name: Renombrar APK
        run: cp build/app/outputs/flutter-apk/app-release.apk "Fragua-${{ github.ref_name }}.apk"

      - uses: actions/upload-artifact@v4
        with:
          name: Fragua-apk
          path: Fragua-*.apk

      - name: Publicar Release con el APK
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@3bb12739c298aeb8a4eeaf626c5b8d85266b0e65 # v2.6.2
        with:
          files: Fragua-*.apk
```

- [ ] **Step 2: Validar la sintaxis YAML del workflow**

```bash
python -c "import yaml,sys; yaml.safe_load(open('.github/workflows/build-android.yml')); print('build-android.yml OK')"
```
Expected: `build-android.yml OK`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/build-android.yml
git commit -m "ci: build del APK firmado + Release en tag v*

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Generar el keystore release y documentar los secrets

**Files:** (sin cambios en el repo; produce un archivo **fuera** del repo + documentación para Alberto)

**Interfaces:**
- Produces: `~/keys/fragua-release.jks` (keystore RSA 2048, validez ~27 años) y los 4 valores a cargar como *secrets* en GitHub: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.

- [ ] **Step 1: Generar el keystore (fuera del repo)**

```bash
mkdir -p ~/keys
STOREPASS="$(openssl rand -base64 24)"
KEYPASS="$STOREPASS"
keytool -genkeypair -v \
  -keystore ~/keys/fragua-release.jks \
  -alias fragua \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "$STOREPASS" -keypass "$KEYPASS" \
  -dname "CN=Fragua, OU=Personal, O=Aranda, L=Madrid, ST=Madrid, C=ES"
echo "STOREPASS=$STOREPASS"
echo "KEYPASS=$KEYPASS"
```
Expected: crea `~/keys/fragua-release.jks` e imprime las contraseñas (idénticas store/key).

- [ ] **Step 2: Calcular el base64 del keystore**

```bash
base64 -w0 ~/keys/fragua-release.jks > ~/keys/fragua-release.jks.base64
wc -c ~/keys/fragua-release.jks.base64
```
Expected: un archivo `.base64` no vacío (el valor de `ANDROID_KEYSTORE_BASE64`).

- [ ] **Step 3: Documentar los 4 secrets para Alberto**

Reunir y entregar a Alberto (para `Settings → Secrets and variables → Actions → New repository secret` en `Albertoac99/Fragua`):

| Secret | Valor |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | contenido de `~/keys/fragua-release.jks.base64` |
| `ANDROID_KEYSTORE_PASSWORD` | `STOREPASS` del Step 1 |
| `ANDROID_KEY_PASSWORD` | `KEYPASS` del Step 1 (= STOREPASS) |
| `ANDROID_KEY_ALIAS` | `fragua` |

> **Custodia:** `~/keys/fragua-release.jks` y sus contraseñas deben guardarse en lugar seguro (gestor de contraseñas / backup). Si se pierden, no se puede volver a firmar **la misma identidad** y las futuras versiones no podrían actualizar el APK in-place. Este archivo NO va al repo (lo cubre `.gitignore`).

- [ ] **Step 4: (sin commit)** — esta tarea no produce cambios versionados.

---

### Task 5: README de build/sideload + verificación final de M9

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: todo lo anterior (workflows, firma, secrets).
- Produces: documentación de uso (build local, CI, firma, sideload) y la verificación end-to-end de M9.

- [ ] **Step 1: Reescribir el README**

Reemplaza el contenido de `README.md` por:
```markdown
# Fragua

Entrenador personal para Android (Flutter): rutinas híbridas fuerza + guiado,
coach auto-regulado, ligas con bots, seguimiento y notificaciones locales.
100 % offline, sin servidor, uso personal.

## Requisitos

- Flutter `3.44.1` (canal `stable`).
- JDK 21 para el build de Android en local (`JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`).

## Desarrollo

```bash
flutter pub get
flutter test          # 118 tests
flutter analyze       # sin issues
flutter run           # en un dispositivo/emulador
```

Tests de los scripts de datos (`tools/`):

```bash
pip install -r tools/requirements.txt
( cd tools && python -m pytest -q )
```

## CI (GitHub Actions)

- **`ci.yml`** — en cada push a `master` y en cada PR: `flutter analyze`, `flutter test` y `pytest` de `tools/`.
- **`build-android.yml`** — al hacer push de un tag `v*` (o `workflow_dispatch`): corre los tests, construye el **APK release firmado** y publica un **Release** con `Fragua-<tag>.apk`.

## Firma release

El APK release se firma con un **keystore propio**. La config vive en
`android/app/build.gradle.kts`, que lee `android/key.properties` si existe y,
en su ausencia, degrada a la debug key (para que `flutter run --release` funcione
en clones sin el keystore). **El keystore y las credenciales nunca se versionan.**

Secrets necesarios en el repo (`Settings → Secrets and variables → Actions`):
`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`,
`ANDROID_KEY_ALIAS`.

Para firmar en **local**, crea `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=fragua
storeFile=/home/kali/keys/fragua-release.jks
```

## Instalación (sideload)

1. Descarga `Fragua-vX.Y.apk` del **Release** correspondiente (pestaña Releases del repo).
2. Pásalo al móvil y ábrelo; permite *instalar apps de orígenes desconocidos*.
3. Como cada Release se firma con el mismo keystore, puedes **actualizar sobre la versión anterior sin desinstalar** (se conserva el historial local).
```

- [ ] **Step 2: Verificación completa local (lo que CI ejecutará)**

```bash
flutter analyze
flutter test
( cd tools && python -m pytest -q )
```
Expected: `No issues found!` · `All tests passed!` (118) · pytest verde.

- [ ] **Step 3: Build del APK release en local (humo)**

```bash
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 flutter build apk --release
ls -lh build/app/outputs/flutter-apk/app-release.apk
```
Expected: APK construido (degradado a debug key sin `key.properties`; valida que el pipeline de empaquetado compila). Si falla por toolchain del host (no por el cambio), documentarlo: el APK firmado definitivo lo produce CI con JDK del runner.

- [ ] **Step 4: Validar ambos YAML**

```bash
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/ci.yml','.github/workflows/build-android.yml']]; print('workflows OK')"
```
Expected: `workflows OK`.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: README de build, firma, CI y sideload (M9)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M9 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (118) · `pytest` de `tools/` verde.
- `android/app/build.gradle.kts` firma el release con keystore propio cuando hay `key.properties`, y degrada a debug en su ausencia (clones sin keystore siguen compilando).
- `.gitignore` cubre `key.properties`, `*.jks`, `*.keystore`; ningún secreto en el repo.
- `ci.yml` y `build-android.yml` con YAML válido; `build-android` usa los 4 secrets y publica Release en tags.
- Keystore `~/keys/fragua-release.jks` generado y custodiado; los 4 secrets entregados a Alberto.
- Mergeado a `master` y pusheado (con el OK de Alberto).

### Handoff a Alberto (acciones manuales, fuera del repo)

1. **Configurar los 4 secrets** en `Albertoac99/Fragua` (Task 4, Step 3).
2. **Disparar el build**: `git tag v1.0 && git push origin v1.0` (con tu OK) → corre `build-android` → publica el Release con `Fragua-v1.0.apk`.
   - Alternativa de prueba sin tag: lanzar `build-android` por `workflow_dispatch` (genera el APK como artifact, sin Release).
3. **Sideload + prueba on-device** (checklist; equivalente a la prueba real de Gambito, spec §13):
   - Instala el APK; abre la app; completa el onboarding; genera un plan.
   - Sesión de fuerza (voz Álvaro, descanso, registro) y una sesión guiada.
   - Liga/racha y pantallas de seguimiento (gráficas).
   - **Notificaciones (cierre de M8 on-device)**: activa el recordatorio (día+hora cercana) y verifica que **llega** la notificación a la hora; acepta el permiso `POST_NOTIFICATIONS`; comprueba que sin permiso la app sigue funcionando.

## Cobertura de la spec (self-review)

- **§1 / §14 M9** — sideload por APK de GitHub Actions, sin Play Store → Tasks 2, 3 (`build-android.yml`), Task 5 (sideload).
- **§5 build** — `build-android.yml` → APK como artifact (y Release), "mismo patrón que Gambito/Legajo" → Task 3 (estructura, pin de `action-gh-release`, tag + dispatch).
- **§11 APK ligero** — los GIFs quedan fuera del APK (M5, descarga bajo demanda); el empaquetado no los añade → respetado (sin assets de GIF en el build).
- **§13 prueba real final** — APK sideloadeado en el móvil físico → Handoff, checklist on-device (incluye el cierre on-device de las notificaciones de M8).
- **§15 0 €** — solo Actions/keytool/herramientas gratis; sin cuenta de Play Store → respetado.
- **Firma estable** (decisión de Alberto, 2026-06-26): keystore propio vía secrets para actualizar in-place sin perder datos → Tasks 1, 3, 4.
- **Fuera de M9** (explícito): publicación en stores, sync Google Fit/Health Connect, modo oscuro y demás "mejoras post-v1" (spec §14) quedan fuera.
```
