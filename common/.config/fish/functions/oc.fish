function oc
    # 1. Generate unique session name based on directory
    set base (basename $PWD | tr '.' '_')"-"(echo $PWD | md5sum | cut -c1-4)
    set session $base
    set i 1

    # 2. Check if a Zellij session with this name already exists
    while zellij list-sessions --no-formatting 2>/dev/null | grep -q "^$session "
        set session "$base-$i"
        set i (math $i + 1)
    end

    # 3. Find the first available port starting at 4096
    set port 4096
    while lsof -i :$port >/dev/null 2>&1
        set port (math $port + 1)
    end

    # 4. Determine if we are already inside a Zellij session
    if set -q ZELLIJ
        # We are inside Zellij: Rename the current pane and run OpenCode
        # This gives the "namer" plugin a hint, or sets it manually
        zellij action rename-pane "OC: $session"
        
        env OPENCODE_PORT=$port opencode --port $port $argv
        
        # Optional: Reset pane name after OpenCode closes
        zellij action rename-pane "fish"
            else
        # We add 'tab name="OpenCode"' to the layout string
        zellij --session "$session" --layout "
            layout {
                tab name=\"OpenCode\" {  // This renames the green bar at the bottom
                    pane name=\"OC: $session\" command=\"sh\" {
                        args \"-c\" \"OPENCODE_PORT=$port opencode --port $port $argv; exec $SHELL\"
                    }
                    pane size=0 {
                        plugin location=\"autoname_tab\"
                    }
                }
            }
        "
    end
end
