#!/usr/bin/env python3
"""BYOC guard: the repository must never carry game data or built binaries.

Bring Your Own Copy: `generated/` (the recompiled game program), disc images,
BIOS dumps and compiled artifacts are produced locally from the player's own
legal disc. This script fails CI if any of them is tracked by git.

Run locally:  python3 tools/ci/check_byoc.py
"""
from __future__ import annotations

import subprocess
import sys

FORBIDDEN_PREFIXES = (
    "generated/",
    "disc/",
    "isos/",
    "bios/",
    "saves/",
)

FORBIDDEN_SUFFIXES = (
    ".bin", ".cue", ".iso", ".img", ".chd", ".pbp", ".mcd", ".mcr",
    ".exe", ".apk", ".aab", ".so", ".dll", ".dylib",
)


def tracked_files() -> list[str]:
    out = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True)
    return [line for line in out.stdout.splitlines() if line.strip()]


def main() -> int:
    bad: list[str] = []
    for path in tracked_files():
        low = path.lower()
        if low.startswith(FORBIDDEN_PREFIXES) or low.endswith(FORBIDDEN_SUFFIXES):
            bad.append(path)
    if bad:
        print("BYOC violation: these tracked files must not be in the repository:")
        for path in bad[:40]:
            print(f"  - {path}")
        if len(bad) > 40:
            print(f"  ... and {len(bad) - 40} more")
        print("\nGenerated game code, disc images and binaries stay local (see .gitignore).")
        return 1
    print(f"BYOC OK: {len(tracked_files())} tracked files, no game data or binaries.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
