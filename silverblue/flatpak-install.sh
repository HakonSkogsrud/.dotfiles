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
  md.obsidian.Obsidian
  org.localsend.localsend_app
  org.onlyoffice.desktopeditors
  org.signal.Signal
)

flatpak install --system --noninteractive flathub "${apps[@]}"

# Allow applications to discover user-installed GTK themes, icons, and GTK
# settings without granting write access to those directories. User overrides
# apply to these system-installed applications for the current account.
for app_id in "${apps[@]}"; do
  flatpak override --user \
    --filesystem=xdg-data/themes:ro \
    --filesystem=xdg-data/icons:ro \
    --filesystem=xdg-config/gtk-3.0:ro \
    --filesystem=xdg-config/gtk-4.0:ro \
    "$app_id"
done
