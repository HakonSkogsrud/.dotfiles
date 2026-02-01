source ~/.config/fish/cachyos-config.fish

function fish_greeting
    # smth smth
end

# BEGIN ANSIBLE MANAGED BLOCK - ALIASES
set -g VIRTUAL_ENV_DISABLE_PROMPT 1
alias restart="source ~/.config/fish/config.fish"
alias proxmox="ssh root@10.0.0.41"
alias proxmox2="ssh root@10.0.0.33"
alias services="ssh haaksk@10.0.0.44"
alias backupserver="ssh haaksk@100.104.43.26"
alias pihole2="ssh haaksk@10.0.0.82"
alias samba="ssh haaksk@10.0.0.79"
alias immich="ssh haaksk@10.0.0.80"
alias github-runner="ssh haaksk@10.0.0.81"
alias loki="ssh haaksk@10.0.0.83"
alias grafana="ssh haaksk@10.0.0.84"
alias pihole="ssh haaksk@10.0.0.77"
alias venv="source .venv/bin/activate.fish"
alias vim="vim"
export EDITOR="vim"
# END ANSIBLE MANAGED BLOCK - ALIASES
