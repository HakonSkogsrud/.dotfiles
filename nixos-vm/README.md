# Proxmox NixOS VM

This host configuration provides GNOME through GDM, SSH, and GNOME Remote Desktop.

Before rebuilding, replace `hardware-configuration.nix` with the generated file from the VM. The checked-in version assumes an ext4 root filesystem labeled `nixos` on a VirtIO disk.

After copying this repository to the VM, build with:

```sh
sudo nixos-rebuild switch --flake .#nixos-vm
```

Set a password for the `haaksk` account before signing in through GNOME Remote Desktop:

```sh
sudo passwd haaksk
```

After signing in locally, enable and configure RDP in **Settings > System > Remote Desktop**. The firewall opens TCP 22 for SSH and TCP/UDP 3389 for RDP.

If Proxmox attaches the boot disk as SCSI rather than VirtIO, update the GRUB device in `configuration.nix` from `/dev/vda` to the actual disk, such as `/dev/sda`.
