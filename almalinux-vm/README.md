# AlmaLinux VM playbook

The inventory targets an existing AlmaLinux VM user with passwordless sudo. The playbook installs the command-line tools from [`../nixos-vm/configuration.nix`](../nixos-vm/configuration.nix), configures git and zsh, and intentionally omits direnv and nix-direnv. It does not manage NixOS boot, hardware, networking, or service settings because this VM runs AlmaLinux.

Run from this directory:

```sh
cp inventory.example.ini inventory.ini
# Edit inventory.ini with the VM's address.
ansible-playbook -i inventory.ini playbook.yml
```

On a machine without Ansible, a temporary copy can be run with:

```sh
UV_CACHE_DIR=/tmp/uv-ansible-cache uv run --no-project --with ansible-core ansible-playbook -i inventory.ini playbook.yml
```

The first run downloads packages from EPEL, npm, GitHub, and nixpkgs. Log out and back in after the run so the new zsh login shell takes effect.
