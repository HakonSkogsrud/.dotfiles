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
alias psmem='ps aux | sort -nr -k 4'
alias psmem10='ps aux | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

zoxide init fish | source
fzf --fish | source

function fish_greeting
    # smth smth
end

set -g VIRTUAL_ENV_DISABLE_PROMPT 1
function cd
    if test (count $argv) -eq 0
        builtin cd ~
    else
        z $argv
    end
end
alias restart="source ~/.config/fish/config.fish"
alias lg="lazygit"
alias venv="source .venv/bin/activate.fish"
alias pc="uv run pre-commit run --all-files"

# fd — modern find replacement
alias find="fd"

# fzf: use fd for file search (respects .gitignore, shows hidden files except .git)
set -x FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_CTRL_T_OPTS "--preview 'bat --color=always --line-range :50 {}' --preview-window=right:50%:wrap"
set -x FZF_ALT_C_COMMAND "fd --type d --hidden --exclude .git"
set -x FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"

# Remap fzf file widget from Ctrl+T (captured by VS Code) to Ctrl+G
bind ctrl-g fzf-file-widget
bind -M insert ctrl-g fzf-file-widget

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/Hakon.Skogsrud/.lmstudio/bin
# End of LM Studio CLI section

