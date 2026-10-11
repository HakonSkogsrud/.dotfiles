# Fedora immutable desktop setup

Desktop-independent setup for Fedora Silverblue and Kinoite. The playbooks
manage applications, fonts, Papirus icons, networking, multimedia codecs, and a
development Toolbx. They do not configure GNOME or KDE desktop preferences.

For a local installation, run Ansible inside a Toolbx and target the host over
SSH. Start in a terminal on the host:

```sh
sudo systemctl enable --now sshd
toolbox create ansible
toolbox enter ansible
```

The following commands run inside the `ansible` Toolbx. Use an SSH connection
so the playbook configures the host rather than the container; do not use
`ansible_connection=local` or `--connection=local`.

Review `vars.yml` for your username, network connection, and hardware. The
default hardware codec package is Intel-specific. Existing inventories must
rename the `[silverblue]` group to `[fedora_immutable]`.

```sh
sudo dnf install -y git ansible openssh-clients sshpass

git clone https://github.com/hakonskogsrud/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/not-in-use/fedora-immutable

ansible-galaxy collection install -r requirements.yml

cp inventory.example.ini inventory.ini
$EDITOR inventory.ini
$EDITOR vars.yml
```

For this local setup, set `inventory.ini` to the host's address and login user:

```ini
[fedora_immutable]
laptop ansible_host=127.0.0.1 ansible_user=YOUR_USERNAME ansible_connection=ssh
```

Toolbx shares the host network, so `127.0.0.1` reaches the host's SSH server.
Set `desktop_user` in `vars.yml` to your host username as well. Verify the SSH
connection from inside Toolbx, then run the playbook:

```sh
ssh YOUR_USERNAME@127.0.0.1 exit
ansible-playbook -i inventory.ini site.yml --ask-pass --ask-become-pass
```

`--ask-pass` prompts for the SSH password; `--ask-become-pass` prompts for the
host's sudo password. Omit `--ask-pass` if SSH key authentication is configured.

Reboot the host when prompted. From a new host terminal, enter Toolbx again
and rerun the playbook:

```sh
toolbox enter ansible
cd ~/.dotfiles/not-in-use/fedora-immutable
ansible-playbook -i inventory.ini site.yml --ask-pass --ask-become-pass
```

After the setup finishes, leave the Ansible Toolbx and run these commands
on the host:

```sh
exit # Leave the ansible Toolbx
sudo tailscale up
toolbox enter dev
```

Papirus is installed for manual selection in your desktop settings. Existing
GNOME preferences and themes from earlier runs are not reset or uninstalled.
