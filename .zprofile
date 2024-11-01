#!/usr/bin/env zsh

# Set scripts path
export PATH="$HOME/.local/bin:$PATH"

# Set Cache Location
export XDG_CACHE_HOME="$HOME/.cache"

# Set Default Config Location
export XDG_CONFIG_HOME="$HOME/.config"

# Set Data Location
export XDG_DATA_HOME="$HOME/.local/share"

# Set .zsh file to config
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Set History File location
export HISTFILE="$XDG_DATA_HOME/history"

# Set neovim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Set default pager to be less
export PAGER="less"

eval "$(/opt/homebrew/bin/brew shellenv)"

