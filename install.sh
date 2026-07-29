#!/usr/bin/env bash
#
# install.sh — install these dotfiles on macOS, per-component opt-in/opt-out.
#
# Usage:
#   ./install.sh                        interactive prompt for each component
#   ./install.sh --yes                  accept defaults, no prompts (Yabai stays OFF)
#   ./install.sh --yabai --yes          also install Yabai (opt-in, off by default)
#   ./install.sh --no-tmux --no-nvim -y only install/link zsh + alacritty
#   ./install.sh --dry-run              show what would happen, change nothing
#
# Components: nvim, tmux, alacritty, zsh (all ON by default), yabai (OFF by default).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ZDOTDIR_TARGET="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

INSTALL_NVIM=1
INSTALL_TMUX=1
INSTALL_ALACRITTY=1
INSTALL_ZSH=1
INSTALL_YABAI=0   # opt-in only — not installed unless explicitly requested

ASSUME_YES=0
DRY_RUN=0
EXPLICIT_FLAGS=0

# ---------- output helpers ----------

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_INFO="$(tput setaf 6)"; C_WARN="$(tput setaf 3)"; C_ERR="$(tput setaf 1)"; C_OK="$(tput setaf 2)"; C_RESET="$(tput sgr0)"
else
  C_INFO=""; C_WARN=""; C_ERR=""; C_OK=""; C_RESET=""
fi

info()  { printf '%s==>%s %s\n' "$C_INFO" "$C_RESET" "$*"; }
ok()    { printf '%s  ✓%s %s\n' "$C_OK" "$C_RESET" "$*"; }
warn()  { printf '%s  !%s %s\n' "$C_WARN" "$C_RESET" "$*"; }
err()   { printf '%sERROR:%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2; }
dry()   { printf '  [dry-run] %s\n' "$*"; }

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

confirm() {
  # confirm "question" DEFAULT(Y|N) — honors --yes / non-interactive
  local prompt="$1" default="${2:-Y}" reply suffix
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  suffix="[Y/n]"; [ "$default" = "N" ] && suffix="[y/N]"
  read -r -p "$prompt $suffix " reply || reply=""
  reply="${reply:-$default}"
  case "$reply" in [Yy]*) return 0 ;; *) return 1 ;; esac
}

# ---------- argument parsing ----------

while [ $# -gt 0 ]; do
  case "$1" in
    --nvim)        INSTALL_NVIM=1; EXPLICIT_FLAGS=1 ;;
    --no-nvim)     INSTALL_NVIM=0; EXPLICIT_FLAGS=1 ;;
    --tmux)        INSTALL_TMUX=1; EXPLICIT_FLAGS=1 ;;
    --no-tmux)     INSTALL_TMUX=0; EXPLICIT_FLAGS=1 ;;
    --alacritty)   INSTALL_ALACRITTY=1; EXPLICIT_FLAGS=1 ;;
    --no-alacritty) INSTALL_ALACRITTY=0; EXPLICIT_FLAGS=1 ;;
    --zsh)         INSTALL_ZSH=1; EXPLICIT_FLAGS=1 ;;
    --no-zsh)      INSTALL_ZSH=0; EXPLICIT_FLAGS=1 ;;
    --yabai)       INSTALL_YABAI=1; EXPLICIT_FLAGS=1 ;;
    --no-yabai)    INSTALL_YABAI=0; EXPLICIT_FLAGS=1 ;;
    --all)         INSTALL_NVIM=1; INSTALL_TMUX=1; INSTALL_ALACRITTY=1; INSTALL_ZSH=1; EXPLICIT_FLAGS=1 ;;
    -y|--yes)      ASSUME_YES=1 ;;
    -n|--dry-run)  DRY_RUN=1 ;;
    -h|--help)     usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

if [ "$(uname -s)" != "Darwin" ]; then
  err "This installer only supports macOS."
  exit 1
fi

if [ "$ASSUME_YES" -eq 0 ] && [ "$EXPLICIT_FLAGS" -eq 0 ] && [ ! -t 0 ]; then
  err "No component flags given and stdin isn't a terminal — pass --yes or explicit flags (see --help)."
  exit 1
fi

# ---------- interactive component selection ----------

if [ "$ASSUME_YES" -eq 0 ] && [ "$EXPLICIT_FLAGS" -eq 0 ]; then
  info "Choose what to install (Enter accepts the default shown):"
  confirm "  Install/configure Neovim?"                Y && INSTALL_NVIM=1      || INSTALL_NVIM=0
  confirm "  Install/configure tmux?"                   Y && INSTALL_TMUX=1      || INSTALL_TMUX=0
  confirm "  Install/configure Alacritty?"               Y && INSTALL_ALACRITTY=1 || INSTALL_ALACRITTY=0
  confirm "  Install/configure Zsh?"                     Y && INSTALL_ZSH=1      || INSTALL_ZSH=0
  confirm "  Install Yabai? (opt-in, off by default)"    N && INSTALL_YABAI=1    || INSTALL_YABAI=0
fi

info "Plan: nvim=$INSTALL_NVIM tmux=$INSTALL_TMUX alacritty=$INSTALL_ALACRITTY zsh=$INSTALL_ZSH yabai=$INSTALL_YABAI dry-run=$DRY_RUN"
if [ "$INSTALL_YABAI" -eq 1 ]; then
  warn "Yabai requires disabling parts of SIP and granting Accessibility permissions manually — this script only installs it, it does not configure your Mac's security settings."
fi
confirm "Proceed?" Y || { info "Aborted."; exit 0; }

# ---------- generic helpers ----------

have_cmd() { command -v "$1" >/dev/null 2>&1; }

link_path() {
  # link_path <source-in-repo> <destination>
  local src="$1" dest="$2"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "link $dest -> $src"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "already linked: $dest"
    return 0
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    warn "backed up existing $dest -> $backup"
  fi
  ln -s "$src" "$dest"
  ok "linked $dest -> $src"
}

brew_install() {
  local formula="$1"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "brew install $formula"
    return 0
  fi
  if brew list --formula --versions "$formula" >/dev/null 2>&1; then
    ok "$formula already installed"
  else
    info "Installing $formula via Homebrew..."
    brew install "$formula"
  fi
}

brew_install_cask() {
  local cask="$1"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "brew install --cask $cask"
    return 0
  fi
  if brew list --cask --versions "$cask" >/dev/null 2>&1; then
    ok "$cask already installed"
  else
    info "Installing $cask via Homebrew (cask)..."
    brew install --cask "$cask"
  fi
}

ensure_homebrew() {
  if have_cmd brew; then
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "install Homebrew"
    return 0
  fi
  confirm "Homebrew isn't installed. Install it now?" Y || { err "Homebrew is required. Aborting."; exit 1; }
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# ---------- base (always) ----------

install_base() {
  info "Linking base git config..."
  link_path "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  if [ "$DRY_RUN" -eq 0 ]; then
    local email; email="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$email" ]; then
      warn "git user.name/user.email are blank in .gitconfig — set them with:"
      warn "    git config --global user.name \"Your Name\""
      warn "    git config --global user.email \"you@example.com\""
    fi
  fi
}

# ---------- components ----------

install_nvim() {
  info "Setting up Neovim..."
  brew_install neovim
  link_path "$DOTFILES_DIR/nvim" "$XDG_CONFIG_HOME/nvim"
  link_path "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
  ok "Neovim config linked (plugins bootstrap automatically on first launch via lazy.nvim)."
}

install_tmux() {
  info "Setting up tmux..."
  brew_install tmux
  link_path "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  link_path "$DOTFILES_DIR/is_vim.sh" "$HOME/.local/bin/is_vim.sh"
  [ "$DRY_RUN" -eq 1 ] || chmod +x "$HOME/.local/bin/is_vim.sh"
  ok "tmux config linked."
}

install_alacritty() {
  info "Setting up Alacritty..."
  brew_install_cask alacritty
  link_path "$DOTFILES_DIR/alacritty.toml" "$XDG_CONFIG_HOME/alacritty/alacritty.toml"
  ok "Alacritty config linked."
}

install_zsh() {
  info "Setting up Zsh..."
  brew_install zsh

  local brew_zsh
  brew_zsh="$(brew --prefix 2>/dev/null || echo /opt/homebrew)/bin/zsh"
  if [ "$DRY_RUN" -eq 0 ] && [ -x "$brew_zsh" ]; then
    grep -qx "$brew_zsh" /etc/shells 2>/dev/null || {
      confirm "Add $brew_zsh to /etc/shells (requires sudo)?" Y && \
        echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
    }
    if [ "${SHELL:-}" != "$brew_zsh" ]; then
      confirm "Set $brew_zsh as your login shell (chsh)?" Y && chsh -s "$brew_zsh"
    fi
  elif [ "$DRY_RUN" -eq 1 ]; then
    dry "add Homebrew zsh to /etc/shells and chsh -s it"
  fi

  brew_install fzf
  if [ "$DRY_RUN" -eq 0 ] && [ ! -f "$HOME/.fzf.zsh" ]; then
    local fzf_prefix; fzf_prefix="$(brew --prefix fzf)"
    "$fzf_prefix/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
  elif [ "$DRY_RUN" -eq 1 ]; then
    dry "run fzf's install script for key-bindings/completion"
  fi

  local fsh_dir="$ZDOTDIR_TARGET/fsh/fast-syntax-highlighting"
  if [ "$DRY_RUN" -eq 0 ]; then
    if [ ! -d "$fsh_dir" ]; then
      mkdir -p "$(dirname "$fsh_dir")"
      git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$fsh_dir"
    else
      ok "fast-syntax-highlighting already present"
    fi
  else
    dry "clone fast-syntax-highlighting into $fsh_dir"
  fi

  link_path "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
  link_path "$DOTFILES_DIR/.zshrc" "$ZDOTDIR_TARGET/.zshrc"
  ok "Zsh config linked (ZDOTDIR=$ZDOTDIR_TARGET)."
}

install_yabai() {
  info "Setting up Yabai..."
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "brew tap koekeishiya/formulae && brew install yabai"
  else
    brew tap koekeishiya/formulae >/dev/null 2>&1 || true
  fi
  brew_install yabai
  link_path "$DOTFILES_DIR/sort_windows.sh" "$HOME/.local/bin/sort_windows.sh"
  [ "$DRY_RUN" -eq 1 ] || chmod +x "$HOME/.local/bin/sort_windows.sh"
  warn "Yabai still needs manual steps: grant Accessibility permissions, and (for the scripting"
  warn "addition) partially disable SIP — see https://github.com/koekeishiya/yabai/wiki."
  warn "Start it with: brew services start yabai"
}

# ---------- main ----------

if [ "$INSTALL_NVIM$INSTALL_TMUX$INSTALL_ALACRITTY$INSTALL_ZSH$INSTALL_YABAI" = "00000" ]; then
  info "Nothing selected — nothing to do."
  exit 0
fi

ensure_homebrew
install_base

[ "$INSTALL_ZSH" -eq 1 ]       && install_zsh
[ "$INSTALL_NVIM" -eq 1 ]      && install_nvim
[ "$INSTALL_TMUX" -eq 1 ]      && install_tmux
[ "$INSTALL_ALACRITTY" -eq 1 ] && install_alacritty
[ "$INSTALL_YABAI" -eq 1 ]     && install_yabai

echo
ok "Done. Open a new terminal (or run 'exec zsh') to pick up shell changes."
