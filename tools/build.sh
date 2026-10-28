#!/usr/bin/env bash
# Alundra Recompiled — BYOC build driver (bring your own copy).
#
# Nothing here needs the game data to be in the repository: the recompiled
# program (`generated/`) is produced locally from YOUR own legal disc.
#
#   tools/build.sh disc    [--disc PATH]   generate game C from your disc
#   tools/build.sh desktop [--disc PATH]   prepare + build the PC executable
#   tools/build.sh android [--disc PATH] [--install]   prepare + build the APK
#
# Environment:
#   PSX_DISC            default disc path (overrides --disc default search)
#   ANDROID_HOME        Android SDK (default: ~/.hermes/android-sdk)
#   JAVA_HOME           JDK 17+ (default: ~/.hermes/jdk when present)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ACTION="${1:-}"; shift || true
DISC="${PSX_DISC:-}"
INSTALL=0
while [ $# -gt 0 ]; do
    case "$1" in
        --disc) DISC="${2:?}"; shift 2 ;;
        --install) INSTALL=1; shift ;;
        -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
done

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

[ -f psxrecomp/runtime/runtime.cmake ] || \
    die "framework missing: run 'git submodule update --init --recursive'"

have_generated() { [ -f generated/*_dispatch.c ] 2>/dev/null; }

# Local portable toolchain (cmake+clang+ninja+SDL3) when the host has none.
use_toolchain() {
    if command -v cmake >/dev/null && command -v ninja >/dev/null && command -v clang >/dev/null; then
        return 0
    fi
    local pack="psxrecomp/.cache/toolchain-pack"
    if [ ! -f "$pack/env.sh" ]; then
        say "downloading portable toolchain (cmake+clang+ninja+SDL3)"
        bash psxrecomp/tools/fetch_toolchain.sh --artifact linux-x64
    fi
    # shellcheck disable=SC1091
    . "$pack/env.sh"
}

prepare_disc() {
    say "generating game C from your own disc"
    use_toolchain
    local args=(generate --project-root "$ROOT")
    [ -n "$DISC" ] && args+=(--disc "$DISC")
    python3 psxrecomp/psxrecomp_cli.py "${args[@]}"
    have_generated || die "generate finished but generated/ has no dispatch table"
}

case "$ACTION" in
    disc)
        prepare_disc
        ;;
    desktop)
        have_generated || prepare_disc
        use_toolchain
        say "building the PC executable"
        cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release \
              -DPSXRECOMP_ROOT="$ROOT/psxrecomp" -DPSX_RECOMP_UI=OFF
        cmake --build build-release -j"$(nproc 2>/dev/null || echo 4)"
        say "done: build-release/psx-runtime (Alundra_Recompiled.exe on Windows)"
        ;;
    android)
        have_generated || prepare_disc
        export ANDROID_HOME="${ANDROID_HOME:-$HOME/.hermes/android-sdk}"
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
        if [ -z "${JAVA_HOME:-}" ] && [ -d "$HOME/.hermes/jdk" ]; then
            export JAVA_HOME="$HOME/.hermes/jdk"
        fi
        [ -f android/local.properties ] || echo "sdk.dir=$ANDROID_HOME" > android/local.properties
        say "building the APK (arm64-v8a)"
        ( cd android && ./gradlew --no-daemon :app:assembleDebug )
        local apk=android/app/build/outputs/apk/debug/app-debug.apk
        say "done: $apk"
        if [ "$INSTALL" = 1 ]; then
            say "installing on the connected device"
            ( cd android && ./gradlew --no-daemon :app:installDebug )
        fi
        ;;
    *)
        sed -n '2,18p' "$0"
        exit 2
        ;;
esac
