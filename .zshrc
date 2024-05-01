# History length and location
HISTSIZE=120000
SAVEHIST=100000
HISTFILE="$XDG_CACHE_HOME/zsh/history"

setopt inc_append_history
setopt extended_history
setopt prompt_subst

# Remove dup commands from HISTFILE
setopt hist_ignore_all_dups

# Set Git branch Colors
setopt PROMPT_SUBST
autoload -U colors && colors

autoload -Uz vcs_info
precmd() { vcs_info }

PROMPT='%F{green}%B%n@%m%f%b:%F{cyan}%B%~%f%b${vcs_info_msg_0_}%(!.#.$) '

# Better ls
alias ls="ls -h --color=auto --group-directories-first"
if [[ -x "$(command -v gls)" ]] then;
    alias ls="gls -h --color=auto --group-directories-first"
    alias ll="gls -hl --color=auto --group-directories-first"
    alias la="gls -hlA --color=auto --group-directories-first"
elif [[ "$OSTYPE" == "linux-gnu"* ]] then;
    alias ls="ls -h --color=auto --group-directories-first"
    alias ll="ls -hl --color=auto --group-directories-first"
    alias la="ls -hlA --color=auto --group-directories-first"
elif [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "freebsd"* ]] then;
    alias ls="ls -hG"
    alias ll="ls -hlG"
    alias la="ls -hlAG"
fi

# Load completions
autoload -Uz compinit && compinit

# Allow select in menus
zstyle ':completion:*' menu select

# Case insensitive matching, prefer exact match
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load module for better completion listing
zmodload zsh/complist

# Autocomplete includes dotfiles
_comp_options+=(globdots)

# Start Vi in zsh
bindkey -v
export KEYTIMEOUT=1

# Vim keys to navigate complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Alias vim to nvim
alias e=$EDITOR
alias vim="nvim"

# Fix backspace in vim mode
bindkey -v '^?' backward-delete-char
zstyle ':vcs_info:git:*' actionformats '(%F{magenta}%b%f|%F{cyan}%a%f)'

# Use Fzf search history
__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-history-widget() {
  fc -RI # Read from histfile
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget

# Syntax highlighting plugin
source "$ZDOTDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" 2> /dev/null

# Iterm shell integration
source ~/.iterm2_shell_integration.zsh
