function oc
    set base (basename $PWD | tr '.' '_')"-"(echo $PWD | md5sum | cut -c1-4)
    set session $base
    set i 1

    while tmux has-session -t "$session" 2>/dev/null
        set session "$base-$i"
        set i (math $i + 1)
    end

    set port 4096
    while lsof -i :$port >/dev/null 2>&1
        set port (math $port + 1)
    end

    if set -q TMUX
        tmux rename-window "OC: $session"
        env OPENCODE_PORT=$port opencode --port $port $argv
        tmux rename-window "fish"
    else
        tmux new-session -d -s "$session" -n "OpenCode" -x (tput cols) -y (tput lines)
        tmux send-keys -t "$session:OpenCode" "cd $PWD && OPENCODE_PORT=$port opencode --port $port $argv" Enter
        tmux attach-session -t "$session"
    end
end
