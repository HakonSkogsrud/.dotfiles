# AlmaLinux VM playbook

The inventory targets an existing AlmaLinux VM user with passwordless sudo. The playbook installs the command-line tools from [`../not-in-use/nixos-vm/configuration.nix`](../not-in-use/nixos-vm/configuration.nix), sets zsh as the login shell, and intentionally omits direnv and nix-direnv. It does not manage NixOS boot, hardware, networking, or service settings because this VM runs AlmaLinux.

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

## Home files

Clone this repository to `~/.dotfiles` on the VM, then install the copied zsh and Codex configuration:

```sh
cd ~/.dotfiles
stow -n -v -t "$HOME" almalinux-home
stow -t "$HOME" almalinux-home
```

The first command previews the links. If Stow reports a conflict with an existing `~/.zshrc` or `~/.codex/config.toml`, inspect that file, move it aside, and run Stow again. An older playbook run may have created `~/.zshrc`; the playbook no longer edits it. The AlmaLinux copy includes the VM's Nix profile path and zsh autosuggestions path.

Git configuration is intentionally local to each machine. This repository does not install a `~/.gitconfig`, so GitHub CLI authentication can update it on the VM.
