# Fedora Silverblue / Kinoite setup

On the host:

```sh
sudo systemctl enable --now sshd
toolbox create ansible
toolbox enter ansible
```

Inside the `ansible` Toolbx:

```sh
sudo dnf install -y git ansible openssh-clients sshpass

git clone https://github.com/HakonSkogsrud/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/not-in-use/fedora-immutable

ansible-galaxy collection install -r requirements.yml
cp inventory.example.ini inventory.ini
```

Set `inventory.ini` to target the host over SSH:

```ini
[fedora_immutable]
laptop ansible_host=127.0.0.1 ansible_user=haaksk ansible_connection=ssh
```

Review your network settings in `vars.yml` (`desktop_user` is `haaksk`), then run:

```sh
ssh haaksk@127.0.0.1 exit
ansible-playbook -i inventory.ini site.yml --ask-pass --ask-become-pass
```

Omit `--ask-pass` when using SSH keys. Reboot the host if prompted, then
reenter `toolbox enter ansible` and rerun the playbook from the same directory.

After setup, return to the host:

```sh
exit
sudo tailscale up
toolbox enter dev
```
