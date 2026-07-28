#!/bin/zsh

# Get number of Displays
display_count=$(yabai -m query --displays | jq '. | length')

# define 1 display spaces
if [ "$display_count" -eq 1 ]; then
    yabai -m space 1 --label "msg"
    yabai -m space 2 --label "search"
    yabai -m space 3 --label "term"

    yabai -m rule --apply app="Google Chrome" space="search"
    yabai -m rule --apply app="Alacritty" space="term"
    yabai -m rule --apply app="iTerm" space="term"
elif [ "$display_count" -eq 2 ]; then
    current_spaces=$(yabai -m query --spaces | jq '. | length')
    needed_spaces=3

    if [ "$current_spaces" -lt "$needed_spaces" ]; then
        for ((i=current_spaces+1; i<=needed_spaces; i++)); do
            yabai -m space --create
        done
    fi
    yabai -m space 1 --label "msg"
    yabai -m space 2 --label "search"
    yabai -m space 3 --label "term"

    yabai -m rule --apply app="Google Chrome" space="search"
    yabai -m rule --apply app="Alacritty" space="term"
    yabai -m rule --apply app="iTerm" space="term"
fi

extra_spaces=$(yabai -m query --spaces | jq '.[] | select(.label == "") | .index')
echo "$extra_spaces" | while read space; do
    yabai -m space "$space" --destroy
done

