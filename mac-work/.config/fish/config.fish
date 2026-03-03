source ~/.config/fish/cachyos-config.fish

zoxide init fish | source
fzf --fish | source

function fish_greeting
    # smth smth
end

set -g VIRTUAL_ENV_DISABLE_PROMPT 1
alias restart="source ~/.config/fish/config.fish"
alias lg="lazygit"
alias venv="source .venv/bin/activate.fish"
