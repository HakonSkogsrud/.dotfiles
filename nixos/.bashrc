alias ls='ls -Alh --group-directories-first --color=auto'

alias lg='lazygit'
alias venv='source .venv/bin/activate'
alias vim='nvim'
alias restart='source ~/.bashrc'
alias ..='cd ..'
alias ...='cd ../..'

alias proxmox='ssh root@10.0.0.41'
alias proxmox2='ssh root@10.0.0.87'
alias services='ssh haaksk@10.0.0.44'
alias backupserver='ssh haaksk@100.80.220.101'
alias pihole2='ssh haaksk@10.0.0.82'
alias samba='ssh haaksk@10.0.0.79'
alias immich='ssh haaksk@10.0.0.80'
alias github-runner='ssh haaksk@10.0.0.81'
alias pihole='ssh haaksk@10.0.0.77'
alias subnet-router='ssh haaksk@10.0.0.78'
alias almadev='ssh haaksk@10.0.0.211'

# Keep history across sessions and share new commands between terminals.
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

_sync_bash_history() {
  history -a
  history -n
}

if [[ " ${PROMPT_COMMAND[*]} " != *"_sync_bash_history"* ]]; then
  PROMPT_COMMAND+=(_sync_bash_history)
fi
