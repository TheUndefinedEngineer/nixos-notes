# QNX on NixOS --- Final Working Setup Guide

## 🎯 Goal

Run:

-   QNX Software Center\
-   QNX SDP (compiler toolchain)\
-   QNX Momentics IDE

on **NixOS**, which does not support generic dynamically linked Linux
binaries by default.

------------------------------------------------------------------------

# 🧠 Why This Is Needed

NixOS does not use a traditional `/usr/lib` layout.\
Proprietary Linux binaries (like QNX tools) expect:

    /usr/lib
    /lib
    /lib64

So we use:

    buildFHSEnv

to create an FHS-compatible environment.

------------------------------------------------------------------------

# 📁 Directory Structure

Example working layout:

    ~/Templates/fsh-shell/
        fshell.sh
        qnx-fhs.nix
        qnxide
        qnxsc

    ~/qnx/
        qnxsoftwarecenter/
        qnxmomenticside/

    ~/qnx800/
        host/
        target/
        qnxsdp-env.sh

------------------------------------------------------------------------

# 🏗 Step 1 --- Create qnx-fhs.nix

Location:

    ~/Templates/fsh-shell/qnx-fhs.nix

Contents:

``` nix
{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "qnx-fhs";

  targetPkgs = pkgs: with pkgs; [
    bash
    coreutils
    glibc
    gcc
    zlib

    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    atk

    libx11
    libxext
    libxrender
    libxtst
    libxi
    libxcursor
    libxrandr
    libxinerama

    libuuid
    libGL
    dbus
    nss
    alsa-lib
    cups
    expat
  ];

  runScript = "bash";
}).env
```

⚠️ Important:

The `}).env` at the end is required.\
Without `.env`, `nix-shell` will not properly enter the FHS environment.

------------------------------------------------------------------------

# 🧰 Step 2 --- Create fshell.sh

Location:

    ~/Templates/fsh-shell/fshell.sh

Contents:

``` bash
#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"

case "$1" in
  qnx)
    nix-shell "$DIR/qnx-fhs.nix" --run "
      source \$HOME/qnx800/qnxsdp-env.sh
      exec bash -i
    "
    ;;
  *)
    echo "Usage: fshell qnx"
    ;;
esac
```

Make executable:

    chmod +x ~/Templates/fsh-shell/fshell.sh

Add directory to PATH (in \~/.bashrc):

    export PATH="$HOME/Templates/fsh-shell:$PATH"

Reload shell:

    source ~/.bashrc

------------------------------------------------------------------------

# 🚀 Step 3 --- Create QNX Launchers

These must be used inside FHS.

## qnxide

Location:

    ~/Templates/fsh-shell/qnxide

Contents:

``` bash
#!/usr/bin/env bash
exec "$HOME/qnx/qnxmomenticside/qde"
```

Make executable:

    chmod +x ~/Templates/fsh-shell/qnxide

## qnxsc

Location:

    ~/Templates/fsh-shell/qnxsc

Contents:

``` bash
#!/usr/bin/env bash
exec "$HOME/qnx/qnxsoftwarecenter/qnxsoftwarecenter"
```

Make executable:

    chmod +x ~/Templates/fsh-shell/qnxsc

------------------------------------------------------------------------

# 🖥 Final Usage Workflow

1️⃣ Enter QNX Dev Environment

    fshell qnx

2️⃣ Launch IDE

    qnxide

3️⃣ Launch Software Center

    qnxsc

------------------------------------------------------------------------

# 🔍 How To Verify FHS Is Active

Inside fshell:

    ls /usr/lib | head

If `/usr/lib` exists → FHS is active.

------------------------------------------------------------------------

# 🏁 Final Status

✔ FHS working\
✔ QNX SDK working\
✔ QNX IDE launching\
✔ Software Center launching\
✔ No stub-ld errors\
✔ Stable across new terminals
