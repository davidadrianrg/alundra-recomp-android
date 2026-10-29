#!/usr/bin/env bash
# Arranca el AVD de Alundra, instala el APK y deja el CHD dentro de la app.
#
# Pensado para el host de desarrollo (x86_64 + KVM). En esta máquina el
# emulador crashea con `Unhandled WRMSR(0xc2)` en el kernel 7.2.8; con el
# 6.19.10 instalado al lado, arranca desde GRUB con ese kernel y este script
# hace el resto.
#
#   tools/emulator-try.sh            # arranca + instala + mete el disco
#   tools/emulator-try.sh --no-start # solo instala y mete el disco (ya arrancado)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK="${ANDROID_HOME:-$HOME/.hermes/android-sdk}"
ADB="$SDK/platform-tools/adb"
AVD="${AVD_NAME:-alundra_tcg}"
APK="${APK:-$ROOT/android/app/build/outputs/apk/debug/app-debug.apk}"
CHD="${CHD:-$HOME/roms/Alundra.chd}"
PKG="com.davidadrianrg.alundra"
START=1
[ "${1:-}" = "--no-start" ] && START=0

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
[ -x "$ADB" ] || { echo "falta adb en $ADB"; exit 1; }
[ -f "$APK" ] || { echo "falta el APK ($APK): compílalo con ./gradlew :app:assembleDebug -PpsxEmulator"; exit 1; }
[ -f "$CHD" ] || { echo "falta el disco ($CHD)"; exit 1; }

if [ "$START" = 1 ]; then
    say "Arrancando $AVD (sin ventana). Si el host crashea: kernel 7.2.8, usa el 6.19.10."
    ANDROID_HOME="$SDK" "$SDK/emulator/emulator" -avd "$AVD" -no-window -no-audio \
        -no-boot-anim -gpu swiftshader_indirect -no-snapshot -memory 2048 -cores 2 \
        > /tmp/emu_alundra.log 2>&1 &
    for i in $(seq 1 40); do
        sleep 15
        bc=$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
        echo "  ... $((i*15))s boot=$bc"
        [ "$bc" = "1" ] && break
        if grep -q EMU_EXIT /tmp/emu_alundra.log 2>/dev/null; then
            echo "el emulador murió:"; tail -3 /tmp/emu_alundra.log; exit 1
        fi
    done
fi

say "Instalando APK"
"$ADB" install -r "$APK" | tail -1

say "Colocando el disco y la config en la app"
"$ADB" shell am force-stop "$PKG"
FILES="/data/data/$PKG/files"
"$ADB" shell "mkdir -p $FILES/gamedata"
"$ADB" push "$CHD" "$FILES/gamedata/Alundra.chd" | tail -1
# game.toml mínimo: el launcher lo escribe, esto lo salta para pruebas por CLI.
"$ADB" shell "cat > $FILES/game.toml <<'EOF'
[game]
name = \"Alundra\"
id = \"SLES-01258\"
players = 1
exe = \"disc/SLES_012.58\"
discs = [
  \"gamedata/Alundra.chd\",
]
load_address = \"0x80020000\"
entry_pc = \"0x800360F4\"
text_size = \"0x0012B000\"
stack_base = \"0x801FFFF0\"

[video]
renderer = \"opengl\"
supersampling = 1
antialiasing = false
texture_filtering = \"xbr\"
aspect_ratio = \"16:9\"

[audio]
buffer_ms = 200
spu_hq = false

[controller]
default_mode = \"digital\"

[bios]
path = \"bios/openbios.bin\"
EOF"

say "Lanzando el juego"
"$ADB" shell am start -n "$PKG/com.psxrecomp.android.PsxGameActivity" >/dev/null
sleep 15
say "Log de arranque"
"$ADB" logcat -d -s psxrecomp | grep -E "first game frame|renderer|error" | tail -5
say "Captura: /tmp/alundra_emu.png"
"$ADB" exec-out screencap -p > /tmp/alundra_emu.png 2>/dev/null
