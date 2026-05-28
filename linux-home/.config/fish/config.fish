# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

fish_add_path ~/.local/bin ~/.cargo/bin

# eza (modern ls)
alias ls='eza -al --color=always --group-directories-first --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias ll='eza -l --color=always --group-directories-first --icons=always'
alias lt='eza -aT --color=always --group-directories-first --icons=always'
alias l.="eza -a | grep -e '^\.'"

# Common utils
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

## Shell tools
zoxide init fish | source
fzf --fish | source
complete -c ansible-playbook -e

# fd as fzf backend
alias find="fd"
set -x FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "fd --type d --hidden --exclude .git"
set -x FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'bat --color=always --line-range :50 {}' --preview-window=right:50%:wrap"

function fish_greeting
    # smth smth
end

set -g VIRTUAL_ENV_DISABLE_PROMPT 1
alias restart="source ~/.config/fish/config.fish"
alias lg="lazygit"
alias venv="source .venv/bin/activate.fish"
alias vim="nvim"
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
alias subnet-router="ssh haaksk@10.0.0.78"
