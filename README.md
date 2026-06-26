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
