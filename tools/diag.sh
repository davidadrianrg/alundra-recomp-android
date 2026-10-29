#!/usr/bin/env bash
# Informe de diagnóstico para el port Android de Alundra.
#
# Uso (con el móvil conectado por USB y depuración activada):
#   tools/diag.sh                 # captura 30 s de logcat + captura de pantalla
#   tools/diag.sh 60              # 60 s
#
# Guarda todo en diag-<fecha>/ y deja un resumen en diag-<fecha>/resumen.txt
# pensado para pegar en el chat: es lo que necesito para tocar rendimiento,
# audio y aspect ratio sin adivinar.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECS="${1:-30}"
PKG="com.davidadrianrg.alundra"
OUT="diag-$(date +%Y%m%d-%H%M%S)"
ADB="${ADB:-adb}"

command -v "$ADB" >/dev/null || { echo "adb no está en PATH (pon ANDROID_HOME/platform-tools o usa ADB=/ruta/adb)"; exit 1; }
"$ADB" get-state >/dev/null 2>&1 || { echo "No hay dispositivo: activa depuración USB y acepta el diálogo"; exit 1; }

mkdir -p "$OUT"
say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }

say "Dispositivo"
{
  echo "### modelo"; "$ADB" shell getprop ro.product.model | tr -d '\r'
  echo "### soc"; "$ADB" shell getprop ro.soc.model | tr -d '\r'
  echo "### android"; "$ADB" shell getprop ro.build.version.release | tr -d '\r'
  echo "### gpu"; "$ADB" shell dumpsys SurfaceFlinger 2>/dev/null | grep -i "GLES:" | head -1 | tr -d '\r'
  echo "### app"; "$ADB" shell dumpsys package "$PKG" 2>/dev/null | grep -E "versionName|versionCode" | head -2 | tr -d '\r'
} > "$OUT/device.txt" 2>&1
cat "$OUT/device.txt"

say "Lanzando la app (si no estaba abierta)"
"$ADB" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true

say "Capturando logcat durante ${SECS}s — juega y cambia las opciones que quieras probar"
"$ADB" logcat -c
"$ADB" logcat -s psxrecomp:V SDL:V AndroidRuntime:E > "$OUT/logcat.txt" 2>&1 &
LOGPID=$!
sleep "$SECS"
kill $LOGPID 2>/dev/null

say "Captura de pantalla"
"$ADB" exec-out screencap -p > "$OUT/pantalla.png" 2>/dev/null

{
  echo "=== resumen $(date) ==="
  echo
  echo "--- modelo / versión ---"
  cat "$OUT/device.txt"
  echo
  echo "--- arranque ---"
  grep -m3 -E "first game frame after|main\(\) entered" "$OUT/logcat.txt" || echo "(sin líneas de arranque: ¿arrancaste el juego?)"
  echo
  echo "--- errores ---"
  grep -m10 -E "^E/|FATAL|signal [0-9]+|SIGSEGV" "$OUT/logcat.txt" || echo "(ninguno)"
  echo
  echo "--- render / vídeo ---"
  grep -m10 -iE "renderer|opengl|gles|resolution|swaps|present" "$OUT/logcat.txt" || echo "(sin líneas)"
  echo
  echo "--- audio ---"
  grep -m10 -iE "audio|spu|underrun|buffer" "$OUT/logcat.txt" || echo "(sin líneas)"
} > "$OUT/resumen.txt"

echo
say "Hecho: $OUT/"
echo "  - $OUT/resumen.txt   (pégalo en el chat)"
echo "  - $OUT/logcat.txt    (log completo)"
echo "  - $OUT/pantalla.png  (captura)"
echo
echo "Repite con cada ajuste que quieras comparar (1x/2x/3x, xBR, 16:9) y pásame el resumen."
