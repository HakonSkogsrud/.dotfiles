# Format man pages
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)
export PATH

# eza (modern ls)
alias ls='eza -al --color=always --group-directories-first --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias ll='eza -l --color=always --group-directories-first --icons=always'
alias lt='eza -aT --color=always --group-directories-first --icons=always'
alias l.="eza -a | grep -e '^\\.'"

# Common utils
alias psmem='ps aux | sort -nr -k 4'
alias psmem10='ps aux | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

cd() {
  if (( $# == 0 )); then
    builtin cd "$HOME"
  else
    z "$@"
  fi
}

alias restart='source ~/.zshrc'
alias lg='lazygit'
alias venv='source .venv/bin/activate'
alias pc='uv run pre-commit run --all-files'
alias find='fd'

# fzf: use fd for file search (respects .gitignore, shows hidden files except .git)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}' --preview-window=right:50%:wrap"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Remap fzf file widget from Ctrl+T (captured by VS Code) to Ctrl+G
if (( $+functions[fzf-file-widget] )); then
  bindkey '^G' fzf-file-widget
fi

path+=("$HOME/.lmstudio/bin")
export PATH

precmd() {
  local prompt_text='%F{cyan}%~%f'

  if [[ -n $VIRTUAL_ENV ]]; then
    prompt_text+=" %F{green} (🐍 ${VIRTUAL_ENV:t})%f"
  fi

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    prompt_text+=" %F{magenta} ($(git rev-parse --abbrev-ref HEAD 2>/dev/null))%f"
  fi

  PROMPT="$prompt_text ❯ "
}
