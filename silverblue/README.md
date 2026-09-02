# Fedora Silverblue migration

These files were generated from the current Fedora Workstation installation.

## Flatpaks

Run as your regular user after first boot:

```sh
./silverblue/flatpak-install.sh
```

The current applications are RapidRAW, Bella, Brief, VSCodium, Obsidian,
Iotas, LocalSend, ONLYOFFICE, and Signal. The script installs them
system-wide, as they are installed now.

## Host-layered services

After Silverblue is ready, run:

```sh
./silverblue/rpm-ostree-layer.sh
```

It layers `ghostty`, `syncthing`, and `tailscale`; the reboot is left to you.
Ghostty is kept native because it is the host terminal used to access
Distrobox, host commands, SSH, and container tooling. Recheck
Syncthing’s existing configuration and data separately before migrating it.

## Development container

Create the Distrobox from this directory:

```sh
distrobox assemble create --file silverblue/dev.ini
```

Enter it with `distrobox enter dev`. The list is based on the installed
toolchain plus the development utilities already declared in this repository.
GUI applications and host services are deliberately excluded.

The current machine has no existing Distrobox or Toolbox containers, so this
is a new environment rather than a conversion of an existing container.
