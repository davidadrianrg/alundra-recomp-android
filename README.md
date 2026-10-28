<div align="center">

# ⚔️ Alundra Recompiled (HD-2D Master Edition)

### *Port nativo para PC (Windows x64) mediante ingeniería inversa y recompilación estática*

> **Fork Android** de [aitorcachero/alundra-recomp](https://github.com/aitorcachero/alundra-recomp).
> Añade una app Android nativa (arm64) con el mismo código recompilado:
> ver [Port Android](#-port-android-esta-fork). El código de PC se mantiene intacto.

[![Platform](https://img.shields.io/badge/Plataforma-Windows%20x64%20Nativo-blue.svg?style=for-the-badge&logo=windows)](https://github.com)
[![Resolution](https://img.shields.io/badge/Resoluci%C3%B3n-Nativa%204K%20UHD%20(3840x2160)-brightgreen.svg?style=for-the-badge)](https://github.com)
[![Framerate](https://img.shields.io/badge/Refresco-120%20%2F%20144%20%2F%20240%20FPS-orange.svg?style=for-the-badge)](https://github.com)
[![Aspect Ratio](https://img.shields.io/badge/Aspecto-16%3A9%20Nativo%20(Sin%20Estirar)-purple.svg?style=for-the-badge)](https://github.com)
[![Textures](https://img.shields.io/badge/Texturas-IA%204x%20Upscale%20(Waifu2x%20CU--Net)-red.svg?style=for-the-badge&logo=nvidia)](https://github.com)
[![License](https://img.shields.io/badge/Licencia-MIT-green.svg?style=for-the-badge)](LICENSE)

---

</div>

## 📖 Descripción

**Alundra Recompiled** es un port para PC nativo (Windows x64) del legendario juego de rol y acción de 1997 desarrollado por **Matrix Software** para la PlayStation 1.

A diferencia de los emuladores tradicionales que interpretan o emulan por software la CPU MIPS R3000A de la PS1, este proyecto utiliza el framework **psxrecomp** para traducir estáticamente el código máquina del juego a código C nativo optimizado, compilado directamente para procesadores modernos x86-64.

El resultado es una versión que corre como una **aplicación nativa de Windows**, con latencia ultrabaja, consumo mínimo de recursos y capacidades gráficas de última generación.

---

## ✨ Características Principales

* 🖥️ **Resolución Interna 4K Ultra HD:** Escalado geométrico de hasta 14x con SSAA (Super-Sampling Anti-Aliasing) y filtrado xBR de alta precisión.
* 📐 **16:9 Panorámico Nativo (Sin Estirar):** El motor gráfico renderiza un lienzo ampliado (+106 píxeles horizontales, 426x240 interno) conservando la proporción 1:1 cuadrada de los píxeles. Ni Alundra ni los círculos se ven deformados ni estirados.
* ⚡ **Framerate Desbloqueado (120+ / 144 / 240 FPS):** Separación total entre el reloj lógico interno (50/60 Hz VBlank) y el hilo de presentación gráfica, permitiendo una fluidez extrema mediante interpolación de fotogramas asíncrona.
* 🎨 **Shader HD-2D Crystal-Clear:** Canal de postprocesamiento a medida que proporciona enfoque uniforme al 100% en toda la pantalla (sin desenfoques molestos en los bordes), realce de micro-detalle y gradación de color vibrante estilo OLED.
* 🤖 **Reescalado de Texturas en Tiempo Real por IA:** Demonio en segundo plano integrado con `waifu2x CU-Net` que aprovecha los núcleos Tensor de tarjetas NVIDIA RTX para reescalar automáticamente todas las texturas del juego a 4K.
* 🌍 **Compatibilidad Multi-Región Universal:** Compatible con imágenes de disco de cualquier región:
  * 🇪🇸 **PAL España:** SLES-01258 *(Edición Oficial en Castellano)*
  * 🇺🇸 **NTSC-U Norteamérica:** SLUS-00553 *(English - 60 Hz)*
  * 🇬🇧 **PAL Europa / UK:** SCES-00840 *(English - 50 Hz)*
  * 🇫🇷 **PAL Francia:** SLES-01257 *(Français)*
  * 🇩🇪 **PAL Alemania:** SLES-01259 *(Deutsch)*
  * 🇯🇵 **NTSC-J Japón:** SCPS-10050 *(日本語)*
* 📦 **Soporte de Formatos Amplio:** Admite `.PBP` (PSX-PSP EBOOTs comprimidos), `.BIN/.CUE`, `.ISO`, `.IMG` y `.CHD`.
* 🔇 **Ejecución Silenciosa:** Scripts optimizados que ocultan ventanas de consola secundarias para una experiencia de juego limpia y profesional.
* 🎮 **Soporte Completo de Mandos:** Compatible con mandos de Xbox, PlayStation DualSense/DualShock, mandos genéricos DirectInput/XInput y teclado. Soporta guardado rápido, rebobinado y vibración.

---

## 🚀 Guía de Inicio Rápido (Para Jugadores)

> **Nota:** Por motivos de derechos de autor, este repositorio **NO** incluye ni distribuye la ROM comercial de Alundra ni BIOS protegidas de PlayStation. Debes proveer tu propia copia legal del juego.

### Paso 1: Preparar tu copia del juego
1. Descarga el archivo comprimido desde la sección **[Releases](https://github.com)** o clona este repositorio.
2. Coloca tu archivo de juego de Alundra (ya sea `.PBP`, `.BIN/.CUE`, `.ISO`, etc.) dentro de la carpeta `alundra_disc/` o en la carpeta raíz del proyecto.
3. Haz doble clic en:
   ```cmd
   PREPARAR_DISCO.bat
   ```
   *El script detectará automáticamente el archivo, lo descomprimirá si es un PBP, identificará el serial y región, y generará las rutas necesarias.*

### Paso 2: Jugar
Haz doble clic en:
* 🎯 **`JUGAR_ALUNDRA.bat`** (Inicia el juego en 4K 16:9 con texturas HD e IA).
* 🔕 **`JUGAR_ALUNDRA_SIN_VENTANAS.vbs`** (Mismo arranque pero 100% silencioso, sin ninguna ventana de consola detrás).

---

## 🕹️ Controles por Defecto

### Teclado
| Acción | Tecla |
|---|---|
| Moverse | Flechas de dirección |
| Botón ❌ (Saltar / Aceptar) | `Z` / `Espacio` |
| Botón 🗡️ (Atacar / Espada) | `X` |
| Botón 🎒 (Inventario) | `C` |
| Botón 🏃 (Correr) | `V` / `Shift` |
| Pausa / Start | `Enter` |
| Menú In-Game / Ajustes | `Esc` / `F1` |
| Guardado Rápido (Save State) | `F5` |
| Carga Rápida (Load State) | `F7` |
| Rebobinado en tiempo real | `R` / `Retroceso` |
| Pantalla Completa | `Alt + Enter` |

*(Los controles son completamente reasignables desde el menú en pantalla pulsando `Esc` o editando `keybinds.ini`).*

---

## 🛠️ Compilación desde el Código Fuente (Desarrolladores)

Si deseas compilar el ejecutable tú mismo desde las fuentes:

### Requisitos:
* **Compilador C/C++:** Clang 18+ o GCC 13+ (recomendado Clang x86_64).
* **CMake:** Versión 3.20 o superior.
* **Ninja:** Build system.
* **Python:** 3.9 o superior.

### Pasos de compilación:
```bash
# 1. Clonar el repositorio con sus submódulos
git clone --recursive https://github.com/TU_USUARIO/alundra-recomp.git
cd alundra-recomp

# 2. Configurar el proyecto con CMake y Ninja
cmake -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release

# 3. Compilar el ejecutable nativo
ninja -C build-release
```

El ejecutable resultante estará en `build-release/Alundra_Recompiled.exe`.

---

## 📦 Qué incluye el repo

Como el repo original, este repositorio **versiona el código recompilado**
(`generated/`, el programa de Alundra traducido a C) y los workflows compilan el
APK desde ahí, sin necesidad de disco.

Lo que **no** incluye ni se distribuye: texturas, audio, FMV, datos de nivel ni
la BIOS del juego. Todo eso lo lee la app de **tu propia copia**, que le indicas
al primer arranque y se importa a su almacenamiento privado.

```bash
git clone --recursive https://github.com/davidadrianrg/alundra-recomp-android.git
cd alundra-recomp-android/android
./gradlew :app:assembleDebug        # JDK 17, SDK 35, NDK 28.2.13676358
./gradlew :app:installDebug         # instala en el móvil por adb
```

O desde la raíz: `tools/build.sh android --install` (y `tools/build.sh disc` solo
si quieres regenerar `generated/` desde tu disco).

**Releases**: al empujar un tag `v*`, el workflow `Release (Android APK)` compila
el APK y lo publica en Lanzamientos como `Alundra-android-arm64-<tag>.apk`.

---

## 📱 Port Android (esta fork)

Esta fork añade la app Android: el mismo código C recompilado se compila para
**arm64** contra el framework `psxrecomp-android` (submódulo `psxrecomp/`), con
menú de arranque para elegir tu disco, pad táctil y menú lateral con save states.

**Controles**

- **Táctil**: pad completo en pantalla (D-pad, botones, L1/R1/L2/R2, Start/Select).
  Se puede **ocultar**: menú → *Controls* → **Touch pad: On/Off**, o control por
  control desde *Edit pad layout…* (mover, escalar, renombrar, ocultar). La
  opacidad se ajusta en el mismo menú y el layout se guarda entre partidas.
- **Mando físico**: cualquier gamepad Bluetooth/USB (Xbox, DualSense, 8BitDo…)
  funciona por SDL; al detectar entrada de mando el pad táctil **se aparta solo**
  y vuelve con el siguiente toque. Teclado y mando se pueden usar a la vez.

```bash
# desde la raíz del repo (con tu disco a mano):
tools/build.sh android --disc /ruta/a/tu/Alundra.cue --install
```

Equivale a generar `generated/` con `psxrecomp_cli.py generate` y luego
`cd android && ./gradlew :app:installDebug` (JDK 17, SDK 35, NDK 28.2.13676358).

Detalles en [`android/README.md`](android/README.md).

Diferencias con la versión de PC en esta fork:

- **Render por defecto en Android: software** (camino verificado). El render
  OpenGL ES está portado pero sin validar en Alundra; el menú permite cambiarlo.
- En Android no hay wizard de primer arranque, ni recomp-ui, ni rewind, ni Vulkan.
- El resto de la experiencia de PC (4K, 16:9, interpolación, shaders HD-2D) sigue
  igual en el target de escritorio.

---

## 📂 Estructura del Proyecto

```text
alundra-recomp/
├── build-release/           # Carpeta de distribución y binario compilado
│   ├── Alundra_Recompiled.exe  # Ejecutable nativo Windows x64
│   ├── game.toml            # Configuración de renderizado y visuales
│   ├── settings.toml        # Preferencias de vídeo, pantalla y mandos
│   └── shaders/             # Shaders GLSL para postprocesamiento HD-2D
│       ├── hd2d.pfx
│       └── hd2d.glsl
├── tools/
│   ├── setup_disc.py        # Extractor y detector universal de discos
│   └── auto_upscale_textures.py # Demonio de reescalado IA waifu2x
├── shaders/                 # Fuentes maestras de shaders
├── PREPARAR_DISCO.bat       # Asistente de preparación de ROMs con 1 clic
├── JUGAR_ALUNDRA.bat        # Lanzador maestro con todas las mejoras activas
├── JUGAR_ALUNDRA_SIN_VENTANAS.vbs # Lanzador silencioso
├── CMakeLists.txt           # Configuración de compilación CMake
└── README.md                # Este documento
```

---

## ⚖️ Aviso Legal y Créditos

* **Alundra** es una marca registrada y propiedad de **Sony Interactive Entertainment Inc.** y **Matrix Software** (1997).
* Este proyecto es una obra de ingeniería inversa con fines educativos, de preservación histórica y compatibilidad moderna.
* No se incluye código propietario con copyright, activos gráficos, música ni datos binarios del juego comercial en este repositorio.
* Basado en el framework [psxrecomp](https://github.com/RetroPortingToolKit/psxrecomp) por el equipo de RetroPortingToolKit.
* Agradecimientos a la comunidad de emulación y decompilación de PlayStation 1 por su continua dedicación a la preservación del videojuego clásico.
