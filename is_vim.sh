#!/usr/bin/env bash

# Get current pane ID and PID
pane_id=$(tmux display-message -p "#{pane_id}")
pane_pid=$(tmux display-message -p "#{pane_pid}")

# Get current pane TTY
pane_tty=$(tmux display-message -p "#{pane_tty}")

# Look for vim/nvim processes using this TTY
vim_processes=$(ps -o pid=,command= -t "$pane_tty" | grep -iE "([gn]?vim|neovim)")

if [ -n "$vim_processes" ]; then
    exit 0
else

    # Alternative method: check pane content for vim
    pane_title=$(tmux display-message -p "#{pane_title}")

    if echo "$pane_title" | grep -iqE "(vim|nvim)"; then
        exit 0
    fi

    # Check current running program name
    current_command=$(tmux display-message -p "#{pane_current_command}")

    if echo "$current_command" | grep -iqE "(vim|nvim)"; then
        exit 0
    fi

    # Additional check for process command directly
    pane_processes=$(ps -o pid=,command= -t "$pane_tty")

    if echo "$pane_processes" | grep -iqE "([gn]?vim|neovim)"; then
        exit 0
    fi
fi

exit 1

