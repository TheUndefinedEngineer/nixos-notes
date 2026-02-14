# STM32 Development on NixOS

**A Reproducible CMake-Based Embedded Workflow Guide**

A clean, reproducible, professional workflow for STM32 (Cortex‑M4) development on NixOS using CMake.

This guide documents:

* Common errors encountered
* Root causes
* Correct fixes
* Final stable architecture
* Reusable template structure

---

# 1. Architecture Overview

We separate the system into TWO clear layers:

## 1️⃣ Development Environment (stm32-develop)

Controls the toolchain and build tools.

Contains:

* `flake.nix`

Provides:

* arm-none-eabi-gcc
* cmake
* ninja
* gdb
* openocd (optional)

Usage:

```bash
nix develop
```
As we need flake for every project I made a template for it and just have to copy it to the project and use it.
```bash
cp -r ~/Template/stm32-develop ~/Workspace/< project name >
``` 

Purpose:

* Ensures compiler exists
* Locks toolchain version
* Prevents "works on my machine" issues
* Avoids system pollution

This does NOT build the project.
It only provides the environment.

---

## 2️⃣ Build System (stm32-build)

Controls compilation and linking.

Contains:

* `cmake/gcc-arm-none-eabi.cmake`
* Linker script
* CMakeLists.txt
* Optional `build.sh`

Design Rules:

* Single canonical ARM flag string
* Always include `-mthumb`
* Use ONE float ABI (hard OR softfp)
* No duplicated flags
* Toolchain logic isolated from project logic

---

# 2. Stable ARM Toolchain Configuration

Canonical flag set for STM32F401:

```
-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
```

Rules:

* Do NOT mix hard and softfp
* Do NOT define flags multiple times
* Keep flags as ONE string (not list)

Correct example:

```
set(ARM_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
```

Incorrect (causes shell splitting errors):

```
set(ARM_FLAGS
  "-mcpu=cortex-m4"
  "-mthumb"
)
```

---

# 3. Standard Build Workflow

## First Build

```
nix develop
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake
cmake --build .
```

## After Code Changes

```
cmake --build build
```

## Clean + Rebuild

```
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake
cmake --build .
```

---

# 4. Common Errors and Fixes

## Error: Bad CMake executable "cube-cmake"

Cause: VSCode overriding CMake path.
Fix: Remove custom `cmake.cmakePath` in settings.

---

## Error: arm-none-eabi-gcc not found

Cause: Not inside `nix develop` shell.
Fix: Run `nix develop`.

---

## Error: "isb 0xF" not supported

Cause: Missing `-mthumb` flag.
Fix: Ensure `-mthumb` is always present.

---

## Error: VFP register argument mismatch

Cause: Mixing `-mfloat-abi=hard` and `softfp`.
Fix: Use only ONE ABI everywhere.

---

## Error: cannot find -lg_nano

Cause: Using `--specs=nano.specs` without nano library.
Fix: Remove nano specs OR ensure toolchain supports it.

---

## Error: "no input files" during compiler test

Cause: Flags defined as list instead of string.
Fix: Combine into single string.

---

## Issue: Nested build/build directory

Cause: Running CMake inside existing build folder.
Fix: Delete build and recreate properly.

---

# 5. Nix Store Size Clarification

Large `/nix/store` size is normal.

Reasons:

* Multiple system generations
* Cached toolchains
* Multiple nixpkgs revisions

To clean old generations:

```
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
sudo nix-collect-garbage -d
```

Important:
Toolchains are stored ONCE globally.
Multiple projects do NOT duplicate them.

---

# 6. Recommended Project Structure

```bash
project/
├── flake.nix
├── flake.lock
├── CMakeLists.txt
├── cmake/
│   └── gcc-arm-none-eabi.cmake
├── Src/
├── Inc/
├── Drivers/
└── build/ (generated)
```

Workflow:

1. Enter environment → `nix develop`
2. Build → `cmake --build build`
3. Rebuild only when toolchain or config changes

---

# 7. Final Result

You now have:

* Reproducible development shell
* Stable ARM toolchain configuration
* Clean rebuild workflow
* No global system dependency pollution
* Template-ready STM32 infrastructure

This is a clean, professional embedded development setup.
