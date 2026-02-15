{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "qnx-fhs";

  targetPkgs = pkgs: (with pkgs; [
    bash
    coreutils
    glibc
    gcc
    zlib

    # GTK + UI deps
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    atk

    # X11
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama

    # Other runtime deps
    libuuid
    libGL
    dbus
    nss
    alsa-lib
    cups
    expat
  ]);

  runScript = "bash";
}).env
