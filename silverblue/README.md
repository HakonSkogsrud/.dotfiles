# Fedora Silverblue

Minimal Ansible configuration for the parts of the laptop that are useful to
keep declarative:

- Tailscale, Syncthing, Avahi, and systemd-resolved
- Configuration of Silverblue's built-in firewalld service
- Ptyxis terminal as a Flatpak and GNOME Tweaks as a host package
- User-local Inter and Comic Shanns Mono, Fantasque Sans Mono, JetBrains Mono, and Commit Mono Nerd Fonts
- User-local Papirus icons with PaleBrown folders
- RPM Fusion's full FFmpeg build and GStreamer codec plugins
- Home-network-only LocalSend and mDNS firewall access
- Loose reverse-path filtering for Tailscale policy routing
- Preference for the physical LAN route to `10.0.0.0/24`
- Bluetooth mouse DPI overrides
- Flatpak desktop applications
- A Fedora Toolbx development environment

The playbooks deliberately do not manage user accounts, authentication,
Tailscale login, Syncthing configuration, login shells,
printer configuration, browser policy, or general hardware tweaks beyond the
declared mouse DPI overrides.

## Run from an Ansible controller

Install the required collections:

```sh
ansible-galaxy collection install -r requirements.yml
```

Create the local inventory and set the laptop address:

```sh
cp inventory.example.ini inventory.ini
$EDITOR inventory.ini
```

Review [`vars.yml`](vars.yml), particularly `desktop_user`,
`home_network_connection`, and `local_subnet`, then run:

```sh
ansible-playbook site.yml --ask-become-pass
```

Run only one part with:

```sh
ansible-playbook networking.yml --ask-become-pass
ansible-playbook multimedia.yml --ask-become-pass
ansible-playbook apps.yml --ask-become-pass
ansible-playbook fonts.yml --ask-become-pass
ansible-playbook appearance.yml --ask-become-pass
ansible-playbook dev-env.yml --ask-become-pass
```

The top-level playbook also supports `networking`, `multimedia`, `apps`,
`fonts`, `appearance`, and `dev` tags:

```sh
ansible-playbook site.yml --tags networking,apps --ask-become-pass
```

The networking RPMs are applied live and also staged in the next rpm-ostree
deployment. RPM Fusion and multimedia packages are staged, so the first
multimedia run adds RPM Fusion and stops; reboot and run it again to stage the
codecs, then reboot once more.

The configured codecs follow RPM Fusion's Atomic Desktop guidance: full
FFmpeg plus the libav, bad-free extras, bad-freeworld, ugly, and VA-API
GStreamer plugins. Commercial DVD CSS decryption is intentionally excluded:
it requires RPM Fusion's separate tainted repository and may be unlawful in
some jurisdictions.

All Flatpaks receive read-only access to the user's font directories. Theme
and color-scheme integration is left to the desktop portal and Flatpak runtime
extensions instead of exposing host GTK configuration. The playbook owns the
user-level global Flatpak override file.

For hardware-accelerated codecs, set
`silverblue_hardware_codec_packages` in [`vars.yml`](vars.yml) to the one
driver appropriate for the GPU:

- Recent Intel: `intel-media-driver`
- Older Intel: `libva-intel-driver`
- AMD: `mesa-va-drivers-freeworld`
- NVIDIA proprietary driver: `libva-nvidia-driver`

When rebasing to a new Fedora major version, replace the RPM Fusion release
packages as part of the rebase, following
[RPM Fusion's OSTree guidance](https://rpmfusion.org/Howto/OSTree). The release
packages are Fedora-version-specific.

LocalSend and mDNS are opened only in firewalld's `home` zone. The
NetworkManager connection named by `home_network_connection` is assigned to
that zone; the default is the home Wi-Fi connection `virus.exe`.

The playbook enables `tailscaled` but does not authenticate the machine or
place `tailscale0` in firewalld's unrestricted `trusted` zone. After the first
run, log in manually:

```sh
sudo tailscale up
```

Syncthing is installed, but its service, configuration, and firewall ports remain manual.

## Development Toolbox

Toolbx is included with Fedora Silverblue. Run `dev-env.yml` to create the
`dev` Toolbx container for the same Fedora release as the host and install the
development tools previously configured on the NixOS VM: editor and shell
tools, Git/GitHub tooling, GCC, Python, Node.js, LazyGit, and Codex. Those
packages stay in the container rather than being layered on the host. Enter it
with:

```sh
toolbox enter dev
```

The playbook refuses to use a non-Toolbx container named `dev` or a Toolbox
from an older Fedora release. After a Fedora major upgrade, remove the old
container with `toolbox rm --force dev` and rerun the playbook. Project files
remain in the shared home directory.

The Nix-specific VM tools (`nixd`, `nixfmt`, and `nix-direnv`) are intentionally
not installed in this Toolbox.

## Fonts

The fonts configured on NixOS are installed in `~/.local/share/fonts` and do
not add their files to the rpm-ostree deployment. Their source versions and
SHA-256 checksums are pinned in [`vars.yml`](vars.yml). Superseded
playbook-managed Nerd Font versions are removed automatically.

## Appearance

Papirus is installed in `~/.local/share/icons`, with its PaleBrown folder
variant applied there. adw-gtk3 is installed in `~/.local/share/themes` and
selected as the GTK3 theme. Its light and dark GTK3 runtime extensions are
installed from Flathub, so GTK3 Flatpaks use the corresponding theme without
a host package layer. GTK4 and libadwaita Flatpaks follow GNOME's color scheme
and accent settings instead. GNOME Tweaks is layered because it needs access
to the host GNOME settings and is not available from Flathub.

## Verify local routing

At home, these commands should show the priority `5000` rule and route the
homelab address over the physical LAN interface:

```sh
ip rule show
ip route get 10.0.0.44
```

Away from home, the rule ignores the main table's default route and permits a
more specific Tailscale route to handle the homelab subnet.
