#!/usr/bin/env bash
set -Eeuo pipefail

# Small host-layer set for services that need to run outside a container.
# Development packages belong in distrobox/dev.ini instead.

if ! command -v rpm-ostree >/dev/null 2>&1; then
  echo "rpm-ostree is not available; run this on Fedora Silverblue." >&2
  exit 1
fi

packages=(
  ghostty
  syncthing
  tailscale
)

sudo rpm-ostree install "${packages[@]}"

cat <<'EOF'

The packages are staged for the next deployment. Reboot, then consider:

  sudo systemctl enable --now tailscaled.service
  tailscale up
  systemctl --user enable --now syncthing.service

Syncthing is intentionally enabled as a user service, matching a desktop
workstation. Use syncthing@<user>.service instead if you want a system service.
EOF
