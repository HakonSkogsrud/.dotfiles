# BEGIN ANSIBLE MANAGED BLOCK - PROMPT
function fish_prompt
    # Current Working Directory (CWD)
    set_color cyan
    echo -n (prompt_pwd)

    # Virtual Environment (Venv)
    if set -q VIRTUAL_ENV
        set_color green
        echo -n ' (🐍 '(basename "$VIRTUAL_ENV")')'
    end

    # Git Branch
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set_color magenta
        echo -n ' ('(git rev-parse --abbrev-ref HEAD 2>/dev/null)')'
    end

    # Final Prompt Separator
    set_color normal
    echo -n ' ❯ '
end
# END ANSIBLE MANAGED BLOCK - PROMPT
