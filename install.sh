#!/usr/bin/env bash
# Bootstrap a fresh machine:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/kzs0/dotfiles/main/install.sh)"
# (or clone the repo anywhere and run ./install.sh). It ends in the setup wizard;
# ./install.sh --yes skips the questions and uses the defaults.
set -euo pipefail

REPO="${DOTFILES_REPO:-kzs0/dotfiles}"
DEST="${DOTFILES:-$HOME/dotfiles}"
OS="$(uname -s)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

if [ "$OS" = Darwin ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    log "installing Xcode Command Line Tools (accept the dialog, then re-run)"
    xcode-select --install; exit 1
  fi
  if ! command -v brew >/dev/null; then
    log "installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  brew install git just gh
  JUST=(just)
else
  if [ ! -e /etc/NIXOS ] && command -v apt-get >/dev/null; then
    log "installing base apt packages (curl, git, xz)"
    sudo apt-get update -qq && sudo apt-get install -y -qq curl git xz-utils ca-certificates
  fi
  if ! command -v nix >/dev/null; then
    log "installing Nix"
    sh <(curl -fsSL https://nixos.org/nix/install) --daemon --yes
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  export NIX_CONFIG="experimental-features = nix-command flakes"
  JUST=(nix run nixpkgs#just --)
  command -v git >/dev/null || alias git='nix run nixpkgs#git --'
fi

if [ ! -d "$DEST/.git" ]; then
  log "cloning $REPO -> $DEST"
  if ! git clone "https://github.com/$REPO.git" "$DEST" 2>/dev/null; then
    log "anonymous clone failed (private repo?) — logging in with gh"
    command -v gh >/dev/null || { echo "install gh, run 'gh auth login', then re-run"; exit 1; }
    gh auth status >/dev/null 2>&1 || gh auth login --git-protocol https --web
    gh repo clone "$REPO" "$DEST"
  fi
fi

cd "$DEST"
log "running just install"
"${JUST[@]}" install "$@"
