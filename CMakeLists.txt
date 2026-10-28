cmake_minimum_required(VERSION 3.20)
set(PSXRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/psxrecomp" CACHE PATH
    "Path to psxrecomp")

if(NOT EXISTS "${PSXRECOMP_ROOT}/runtime/runtime.cmake")
    message(FATAL_ERROR
        "PSXRecomp runtime is missing: ${PSXRECOMP_ROOT}/runtime/runtime.cmake\n"
        "This project expects the psxrecomp-android framework checkout at ${PSXRECOMP_ROOT}.\n"
        "Run: git submodule update --init --recursive\n"
        "If psxrecomp/ is not a submodule, set -DPSXRECOMP_ROOT=<path-to-psxrecomp>.")
endif()

project(AlundraRecomp LANGUAGES C CXX)

# --- Android build (the port this fork exists for) --------------------------
if(ANDROID)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        # Keep the debug APK debuggable while optimizing the CPU-bound PS1
        # runtime: the Android debug variant otherwise compiles the emulator at
        # -O0, which is unusable on a phone.
        add_compile_options(-O3 -flto=thin)
        add_link_options(-flto=thin)
    endif()
    # libmain.so is the whole game; nothing interposes its symbols. Hidden
    # visibility lets the compiler address runtime globals PC-relative instead
    # of loading each address from the GOT (the per-instruction cycle helpers
    # touch several globals per guest instruction). Only JNIEXPORT functions
    # and SDL_main need to stay visible.
    add_compile_options(-fno-semantic-interposition -fvisibility=hidden
                        $<$<COMPILE_LANGUAGE:CXX>:-fvisibility-inlines-hidden>)
    add_link_options(-Wl,-Bsymbolic)
    set(PSX_REWIND OFF CACHE BOOL "Android: no rewind snap-ring backend" FORCE)
    set(PSX_RECOMP_UI OFF CACHE BOOL "Android: no desktop launcher UI" FORCE)
    # Con el submódulo recomp-ui presente, main.cpp ve su cabecera por
    # __has_include y llamaría a un provider que en Android no se compila.
    add_compile_options(-DPSX_NO_RECOMP_UI_PROVIDER=1)
    set(PSX_ENABLE_VULKAN OFF CACHE BOOL "Android: no Vulkan renderer" FORCE)
    set(PSX_SETUP_WIZARD OFF CACHE BOOL "Android: the start menu picks the disc" FORCE)
    set(PSX_PRELOADED_MODS "NONE")
endif()

# --- Desktop / release surfaces (unchanged from upstream) -------------------
if(NOT ANDROID)
    # Scaffold prompts / flags fill these. Without recomp-ui, PSX_RECOMP_UI is OFF.
    # The wizard (WIZARD_CMAKE_BLOCK / ENABLE_SETUP_WIZARD) is the first-run disc
    # picker; releases are compiled from the committed generated/ C, so it never
    # needs to generate or rebuild anything on a player's machine.
    set(PSX_SETUP_WIZARD ON CACHE BOOL
        "Advertise first-run setup wizard + Generate & rebuild in recomp-ui" FORCE)
endif()
include("${PSXRECOMP_ROOT}/runtime/runtime.cmake")

# This project's own mod catalog. The FRAMEWORK stages it -- together with its
# builtin psx.* packages -- into <exe-dir>/mods/bundled, and refuses to
# configure if a catalog exists here but is not declared.
if(NOT ANDROID)
    set(PSX_PRELOADED_MODS "${CMAKE_CURRENT_SOURCE_DIR}/mods/preloaded")
    if(NOT IS_DIRECTORY "${PSX_PRELOADED_MODS}")
        set(PSX_PRELOADED_MODS "NONE")
    endif()
endif()

if(ANDROID)
    psxrecomp_add_game_runtime(psx-runtime
        PRELOADED_MODS_DIR "${PSX_PRELOADED_MODS}"
        WINDOW_TITLE "Alundra"
        DEFAULT_GAME_CONFIG_PATH "game.toml"
        MAX_PLAYERS 1
        GEN_MARKER "generated/SLES_012.58_dispatch.c"
        GEN_FULL_GLOB "generated/SLES_012.58_full_*.c"
    )
    # SDL's Android Activity loads the game entry point from libmain.so.
    set_target_properties(psx-runtime PROPERTIES OUTPUT_NAME main)
else()
    psxrecomp_add_game_runtime(psx-runtime
        PRELOADED_MODS_DIR "${PSX_PRELOADED_MODS}"
        ENABLE_SETUP_WIZARD
        WINDOW_TITLE "Alundra Recompiled"
        DEFAULT_GAME_CONFIG_PATH "game.toml"
        MAX_PLAYERS 1
        # LAUNCHER_BOXART "${CMAKE_CURRENT_SOURCE_DIR}/launcher_assets/img/boxart.tga"
        APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/psxrecomp.ico"
        # Committed game C (psxrecomp_cli.py generate; git add generated). Release
        # CI configures with -DPSXRECOMP_REQUIRE_GAME_C=ON so a checkout without
        # it fails instead of building a setup host.
        GEN_MARKER "generated/SLES_012.58_dispatch.c"
        GEN_FULL_GLOB "generated/SLES_012.58_full_*.c"
        CODEGEN_SETUP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/codegen_setup.c"
    )
endif()

# Stage runtime configs next to the exe for direct build/ launches. Android takes
# its config from the APK's assets/game.toml.in instead (the start menu writes
# files/game.toml at first run). Only copy files that exist — never fail
# POST_BUILD when game_options.toml is absent.
if(NOT ANDROID)
    foreach(_PSX_RUNTIME_CONFIG game.toml game_options.toml)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_PSX_RUNTIME_CONFIG}")
            add_custom_command(TARGET psx-runtime POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${CMAKE_CURRENT_SOURCE_DIR}/${_PSX_RUNTIME_CONFIG}"
                    "$<TARGET_FILE_DIR:psx-runtime>/${_PSX_RUNTIME_CONFIG}"
                COMMENT "Staging ${_PSX_RUNTIME_CONFIG}"
                VERBATIM)
        endif()
    endforeach()
endif()
