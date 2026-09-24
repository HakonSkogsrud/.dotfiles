# Silverblue setup

```sh
toolbox create ansible
toolbox enter ansible

sudo dnf install -y git ansible

git clone https://github.com/hakonskogsrud/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/silverblue

ansible-galaxy collection install -r requirements.yml

cp inventory.example.ini inventory.ini
$EDITOR inventory.ini
$EDITOR vars.yml

ansible-playbook site.yml --ask-become-pass
```

Reboot when prompted, enter the Toolbx again, and rerun the playbook:

```sh
toolbox enter ansible
cd ~/.dotfiles/silverblue
ansible-playbook site.yml --ask-become-pass
```

After the setup finishes:

```sh
sudo tailscale up
toolbox enter dev
```
