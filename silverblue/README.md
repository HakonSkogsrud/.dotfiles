# Fedora Silverblue setup

This is a command-only migration runbook for the NixOS configuration in
`../nixos`. Run the commands as the normal desktop user after the first
Silverblue boot. They are safe to repeat after each reboot.

This README is the runbook; do not run the older `.sh` helpers in this
directory. In particular, the old host-layer helper still includes Syncthing.

Syncthing is intentionally absent. Install, configure, and open its firewall
ports yourself.

## 2. Layer the small host set

These are host packages because they provide the terminal, services, device
integration, or system codecs. Development packages stay in the Distrobox
below. `--idempotent` and `--allow-inactive` make an already-present package a
no-op.

```sh
sudo rpm-ostree install --idempotent --allow-inactive \
  avahi \
  firewalld \
  fwupd \
  ghostty \
  intel-media-driver \
  nss-mdns \
  power-profiles-daemon \
  rsms-inter-fonts \
  tailscale \
  unzip \
  zsh \
  zsh-autosuggestions
```

Reboot before using newly layered host packages:

```sh
systemctl reboot
```

## 3. Install the Flatpaks

The list is the existing Silverblue list plus the Flatpaks declared by the
Nix configuration. No additional GUI applications or Firefox configuration is
included.

```sh
sudo flatpak remote-add --system --if-not-exists \
  flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpaks=(
  io.github.CyberTimon.RapidRAW
  io.github.josephmawa.Bella
  org.gnome.World.Iotas
  com.visualstudio.code
  md.obsidian.Obsidian
  org.localsend.localsend_app
  org.onlyoffice.desktopeditors
  org.signal.Signal
)

sudo flatpak install --system --noninteractive flathub "${flatpaks[@]}"

# Let the system-installed Flatpaks use the user's GTK themes and icons.
for app_id in "${flatpaks[@]}"; do
  flatpak override --user \
    --filesystem=xdg-data/themes:ro \
    --filesystem=xdg-data/icons:ro \
    --filesystem=xdg-config/gtk-3.0:ro \
    --filesystem=xdg-config/gtk-4.0:ro \
    "$app_id"
done

# RapidRAW's NixOS override granted it access to this directory.
flatpak override --user \
  --filesystem="$HOME/Photos" \
  io.github.CyberTimon.RapidRAW
```

## 4. Fonts

Fedora packages provide Inter. The four Nerd Fonts below are installed in the
user profile from the pinned Nerd Fonts release, so rerunning this block
overwrites the same files without creating duplicates.

```sh
font_tmp="$(mktemp -d)"
trap 'rm -rf "$font_tmp"' EXIT
font_dir="$HOME/.local/share/fonts"
install -d -m 0755 "$font_dir"

for font in ComicShannsMono FantasqueSansMono JetBrainsMono CommitMono; do
  curl --fail --location --silent --show-error \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/${font}.zip" \
    --output "$font_tmp/${font}.zip"
  unzip -oq "$font_tmp/${font}.zip" -d "$font_dir"
done

fc-cache -f "$font_dir"
```

Apply the NixOS Inter defaults and input settings to the current GNOME user
session. These commands are harmless to repeat.

```sh
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'no')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
gsettings set org.gnome.desktop.peripherals.touchpad tap-and-drag false
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
```

## 5. Bluetooth mouse hwdb settings

This is the Fedora equivalent of `services.udev.extraHwdb` in the Nix
configuration.

```sh
sudo install -d -m 0755 /etc/udev/hwdb.d
sudo tee /etc/udev/hwdb.d/90-local-mouse.hwdb >/dev/null <<'EOF'
mouse:bluetooth:v1915p0040:name:*:
 MOUSE_DPI=2000@1000

mouse:bluetooth:v046Dp0B020:name:*:
 MOUSE_DPI=1800@1000
EOF

sudo systemd-hwdb update
sudo udevadm trigger --subsystem-match=input --action=change
```

Reconnect the mouse, or reboot, if its current DPI does not change
immediately.

## 6. RPM Fusion and the non-free FFmpeg stack

Silverblue needs the RPM Fusion release packages layered before it can use
RPM Fusion codecs. The release URLs select the Fedora version automatically.

```sh
sudo rpm-ostree install --idempotent --allow-inactive \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

systemctl reboot
```

After reboot, swap Fedora's restricted FFmpeg libraries for RPM Fusion's
full FFmpeg package. The status check prevents a completed swap from being
requested again. Reboot after a new transaction is staged.

```sh
if rpm -q --quiet ffmpeg; then
  echo 'FFmpeg is already installed.'
elif rpm-ostree status --json | grep -q '"ffmpeg"'; then
  echo 'The FFmpeg transaction is already staged; reboot to apply it.'
else
  codec_free_packages=(
    ffmpeg-free
    libavcodec-free
    libavdevice-free
    libavfilter-free
    libavformat-free
    libavutil-free
    libpostproc-free
    libswresample-free
    libswscale-free
  )
  installed_free_packages=()
  for package in "${codec_free_packages[@]}"; do
    if rpm -q --quiet "$package"; then
      installed_free_packages+=("$package")
    fi
  done

  if ((${#installed_free_packages[@]})); then
    sudo rpm-ostree override remove \
      "${installed_free_packages[@]}" \
      --install ffmpeg
  else
    sudo rpm-ostree install --idempotent --allow-inactive ffmpeg
  fi
fi
```

```sh
systemctl reboot
```

## 7. Tailscale, Avahi, firewall, and DNS

Enable the services. `tailscale up` is only called when this machine does not
already have a Tailscale address, so re-running the block does not repeatedly
ask for authentication.

```sh
sudo systemctl enable --now tailscaled.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now fwupd.service
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now firewalld.service

if ! sudo tailscale ip >/dev/null 2>&1; then
  sudo tailscale up
fi
```

Configure the NixOS firewall equivalent. The active default zone is detected,
so this does not assume that it is named `public`. The Tailscale interface is
placed in the `trusted` zone once it exists.

```sh
firewall_zone="$(sudo firewall-cmd --get-default-zone)"

sudo firewall-cmd --permanent --zone="$firewall_zone" --add-port=53317/tcp
sudo firewall-cmd --permanent --zone="$firewall_zone" --add-port=53317/udp
sudo firewall-cmd --permanent --zone="$firewall_zone" --add-port=41641/udp
sudo firewall-cmd --permanent --zone="$firewall_zone" --add-service=mdns

if ip link show tailscale0 >/dev/null 2>&1; then
  old_zone="$(sudo firewall-cmd --get-zone-of-interface=tailscale0 2>/dev/null || true)"
  if [ "$old_zone" != trusted ]; then
    if [ -n "$old_zone" ]; then
      sudo firewall-cmd --permanent --zone="$old_zone" --remove-interface=tailscale0 || true
    fi
    sudo firewall-cmd --permanent --zone=trusted --add-interface=tailscale0
  fi
fi

sudo firewall-cmd --reload
```

The Nix firewall opened TCP/UDP `53317`, the Tailscale UDP port, and Avahi
mDNS. Syncthing's ports are not opened here; add them as part of your own
Syncthing setup if you need them.

Apply the NixOS `checkReversePath = "loose"` equivalent for policy routing:

```sh
sudo tee /etc/sysctl.d/90-local-routing.conf >/dev/null <<'EOF'
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
EOF

sudo sysctl --system
```

Configure `systemd-resolved` with the NixOS `~.` fallback domain and make its
stub resolver the system resolver:

```sh
sudo install -d -m 0755 /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/99-default-fallback.conf >/dev/null <<'EOF'
[Resolve]
Domains=~.
EOF

sudo systemctl enable --now systemd-resolved.service
sudo ln -sfn ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved.service
```

## 8. Persistent local-subnet policy rule

This reproduces the NixOS service that forces `10.0.0.0/24` through the main
routing table at priority `5000`. The delete-before-add makes both startup
and manual restarts idempotent.

```sh
sudo tee /etc/systemd/system/local-network-policy-rule.service >/dev/null <<'EOF'
[Unit]
Description=Route the local subnet through the main routing table
Wants=NetworkManager-wait-online.service tailscaled.service
After=NetworkManager-wait-online.service tailscaled.service
Before=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=-/usr/sbin/ip rule del to 10.0.0.0/24 priority 5000 table main
ExecStart=/usr/sbin/ip rule add to 10.0.0.0/24 priority 5000 table main
ExecStop=-/usr/sbin/ip rule del to 10.0.0.0/24 priority 5000 table main

[Install]
WantedBy=network-online.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable local-network-policy-rule.service
sudo systemctl restart local-network-policy-rule.service
```

Verify the rule:

```sh
ip rule show | grep -F 'to 10.0.0.0/24 priority 5000'
ip route get 10.0.0.44
```

## 9. Shell and development container

Make Zsh the login shell, then create the development container defined in
[`dev.ini`](dev.ini). The guard prevents a second container from being
created if this runbook is repeated.

```sh
zsh_path="$(command -v zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]; then
  chsh -s "$zsh_path"
fi

if ! distrobox list --no-color | grep -qE '(^|[[:space:]])dev([[:space:]]|$)'; then
  distrobox assemble create --file silverblue/dev.ini
fi
```

Enter it with:

```sh
distrobox enter dev
```
