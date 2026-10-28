# Alundra — port Android (recompilación estática)

Esta carpeta es una app Android (Gradle + NDK + CMake) que compila el **mismo**
código C recompilado de Alundra que usa la versión de PC, contra el *framework*
`psxrecomp-android` (submódulo `psxrecomp/`). No es un emulador: el programa MIPS
de la PS1 se traduce a C y se compila para arm64.

## Requisitos

- JDK 17+ (`JAVA_HOME`).
- Android SDK con **platform 35**, **build-tools 35** y **NDK 28.2.13676358**
  (el `ndkVersion` del `build.gradle`).
- CMake 3.22.1 del SDK y `adb` para instalar.
- Un dispositivo o emulador **arm64-v8a** (Android 5+, `minSdk 21`).

`local.properties` debe apuntar al SDK:

```properties
sdk.dir=/ruta/a/Android/Sdk
```

## Compilar e instalar

```bash
cd android
./gradlew :app:assembleDebug          # APK debug
./gradlew :app:installDebug           # compila e instala por adb
```

El APK se genera en `android/app/build/outputs/apk/debug/app-debug.apk`.
Build "de juego" (sin servidor de debug, más rápido en el móvil):
`./gradlew :app:assembleDebug -PpsxPlayBuild`.

## Primera ejecución en el móvil

1. Abre la app → menú lateral → **Select game file**.
2. Navega a tu copia legal del disco (`.cue` + `.bin`, `.iso` o `.chd`) y
   selecciónala. Los ficheros se copian al almacenamiento privado de la app
   (`files/gamedata/`) y se escribe `files/game.toml`.
3. **Play**. El botón superior central abre el menú: guardar/cargar estado,
   cambiar de disco, reiniciar, opciones de pantalla y mando en pantalla.

## Qué trae la capa Android

- Menú de arranque para elegir el disco (no se empaqueta ningún dato del juego).
- Pad táctil configurable (posición y tamaño), sticks analógicos opcionales y
  trackpad para juegos con ratón PS1.
- Menú lateral con 12 ranuras de save state, cambio de disco, reinicio, opciones
  de render (software / OpenGL ES experimental) y contador de FPS.
- BIOS: se empaqueta **OpenBIOS** (MIT) desde `psxrecomp/bios/`.

## Estado de este port

- Render por defecto: **software** (el camino verificado en la capa Android).
  `[video] renderer = "opengl"` (OpenGL ES) está portado pero sin validar en
  Alundra.
- El código recompilado (`generated/`) se compila tal cual; no hace falta
  recompilar en el móvil ni tener el disco para compilar el APK.

## Aviso legal

Uso personal y no comercial (PolyForm Noncommercial, igual que `psxrecomp`).
Necesitas tu propia copia de Alundra. **No distribuyas APKs**: contienen el
programa traducido del juego.

## Controles

- **Pad táctil ocultable**: menú → *Controls* → **Touch pad: On/Off**; por control
  individual en *Edit pad layout…*; opacidad ajustable. El layout se guarda.
- **Mando físico**: gamepads por SDL (Xbox/DualSense/8BitDo/…). Al detectar mando
  el pad táctil se oculta solo y reaparece al tocar la pantalla.
