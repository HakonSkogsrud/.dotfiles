# `nixos-proxmox`: headless development VM

This profile turns a freshly installed Proxmox NixOS VM into the headless
development server at `10.0.0.91`. It contains SSH and the common development
toolchain, but no desktop environment, graphical applications, Flatpaks,
Tailscale, or Syncthing.

The VM is intended to be used through VS Code's **Remote - SSH** extension.
VS Code installs its server, extensions, language servers, terminals, and
debuggers directly on the VM.

## First boot after the NixOS installer

Complete the normal NixOS installation in the Proxmox console, then boot the
installed VM and log in as `root`. The initial NixOS configuration must have
working network access.

The installer generated the VM-specific `/etc/nixos/hardware-configuration.nix`.
Leave that file in place for the next step. Temporarily obtain Git and clone
the dotfiles repository:

```sh
nix-shell -p git --run \
  'git clone https://github.com/hakonskogsrud/.dotfiles /etc/nixos/dotfiles'
```

Replace the repository's generic VM hardware file with the installer-generated
one:

```sh
install -Dm644 \
  /etc/nixos/hardware-configuration.nix \
  /etc/nixos/dotfiles/nixos-vm/hardware-configuration.nix
```

Build and activate the headless profile:

```sh
nixos-rebuild switch \
  --flake /etc/nixos/dotfiles/nixos#nixos-proxmox
```

The VM now identifies itself as `nixos-proxmox`, starts SSH, and opens only
TCP port 22 in its NixOS firewall. The configuration uses DHCP; reserve
`10.0.0.91` for the VM in your DHCP server or configure a static address there.

## Enable SSH access

Set the account password once from the Proxmox console:

```sh
passwd haaksk
```

From your Silverblue machine, copy an SSH key:

```sh
ssh-copy-id nixos-proxmox
ssh nixos-proxmox
```

The corresponding client entry is:

```sshconfig
Host nixos-proxmox
  HostName 10.0.0.91
  User haaksk
```

After key authentication works, you can tighten SSH further by disabling
password authentication in `configuration.nix` and rebuilding.

## Connect with VS Code

Install the **Remote - SSH** extension in native VS Code on Silverblue, run
**Remote-SSH: Connect to Host...**, and choose `nixos-proxmox`. Open or clone
your repositories under `/home/haaksk` from the remote VS Code window.

## Maintenance

Update the configuration from the VM with:

```sh
cd /etc/nixos/dotfiles
sudo git pull
sudo nixos-rebuild switch --flake .#nixos-proxmox
```

If Proxmox attaches the boot disk as SCSI rather than VirtIO, update the GRUB
device in `configuration.nix` from `/dev/vda` to the actual disk, such as
`/dev/sda`.
