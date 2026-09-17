# Fedora Silverblue

Minimal Ansible configuration for the parts of the laptop that are useful to
keep declarative:

- Tailscale, Avahi, firewalld, and systemd-resolved
- LocalSend and mDNS firewall access
- Loose reverse-path filtering for Tailscale policy routing
- Preference for the physical LAN route to `10.0.0.0/24`
- Non-development Flatpak applications

The playbooks deliberately do not manage GNOME settings, user accounts,
authentication, Tailscale login, Syncthing, development tools, fonts, shells,
printing, browser policy, hardware tweaks, or RPM Fusion.

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

Review [`vars.yml`](vars.yml), particularly `desktop_user`, `desktop_home`,
and `local_subnet`, then run:

```sh
ansible-playbook site.yml --ask-become-pass
```

Run only one part with:

```sh
ansible-playbook networking.yml --ask-become-pass
ansible-playbook apps.yml --ask-become-pass
```

The host RPMs are applied live and also staged in the next rpm-ostree
deployment. Reboot when the play reports that rpm-ostree has created a pending
deployment.

The playbook enables `tailscaled` but does not authenticate the machine. After
the first run, log in manually:

```sh
sudo tailscale up
```

Syncthing and its firewall ports remain entirely manual.

## Verify local routing

At home, these commands should show the priority `5000` rule and route the
homelab address over the physical LAN interface:

```sh
ip rule show
ip route get 10.0.0.44
```

Away from home, the rule ignores the main table's default route and permits a
more specific Tailscale route to handle the homelab subnet.
