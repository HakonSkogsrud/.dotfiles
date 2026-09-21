# Fedora Workstation setup

These playbooks configure a regular, mutable Fedora Workstation installation.
They deliberately reject rpm-ostree/Atomic hosts. Applications are installed as
RPMs when a suitable Fedora or vendor RPM exists; the remaining GUI applications
use Flathub. Ptyxis is not installed.

```sh
sudo dnf install -y git ansible
git clone https://github.com/hakonskogsrud/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/fedora-ansible
ansible-galaxy collection install -r requirements.yml
$EDITOR vars.yml
ansible-playbook site.yml --ask-become-pass
```

After the playbook finishes, authenticate Tailscale if needed:

```sh
sudo tailscale up
```
