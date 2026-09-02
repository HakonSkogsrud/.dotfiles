#!/usr/bin/env bash
set -Eeuo pipefail

# Install the applications present on the Fedora Workstation snapshot.
# Run as the normal user; --system is used because the current installations
# are system-wide Flatpaks.

if ! command -v flatpak >/dev/null 2>&1; then
  echo "flatpak is not installed. Install it first, then re-run this script." >&2
  exit 1
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

apps=(
  io.github.CyberTimon.RapidRAW
  io.github.josephmawa.Bella
  io.github.shonebinu.Brief
  com.vscodium.codium
  md.obsidian.Obsidian
  org.gnome.World.Iotas
  org.localsend.localsend_app
  org.onlyoffice.desktopeditors
  org.signal.Signal
)

flatpak install --system --noninteractive flathub "${apps[@]}"
