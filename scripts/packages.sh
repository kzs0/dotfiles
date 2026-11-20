#!/usr/bin/env bash
# Packages: ./Brewfile on macOS, ./nix/packages.nix via Home Manager on Linux.
. "$(dirname "$0")/lib.sh"

# Linux Home Manager profile: cli (Ubuntu/servers) or desktop (NixOS, adds ghostty + zed)
HM_TARGET="${DOTFILES_PROFILE:-cli}-$(uname -m | sed 's/arm64/aarch64/')-linux"
export NIX_CONFIG="experimental-features = nix-command flakes"

install() {
  if is_mac; then
    command -v brew >/dev/null || { say "Homebrew missing — run ./install.sh first"; exit 1; }
    brew bundle --file "$DOTFILES/Brewfile"
    return
  fi
  if ! command -v nix >/dev/null; then
    say "installing Nix"
    sh <(curl -fsSL https://nixos.org/nix/install) --daemon --yes
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  local hm=(home-manager); command -v home-manager >/dev/null || hm=(nix run home-manager/master --)
  "${hm[@]}" switch --impure -b hm-backup --flake "$DOTFILES#$HM_TARGET"
}

update() {
  is_mac || nix flake update --flake "$DOTFILES"
  install
}

remove() {
  confirm "Uninstall every package from the Brewfile / Home Manager profile?" || exit 0
  if is_mac; then
    brew bundle list --file "$DOTFILES/Brewfile" --cask | xargs -r brew uninstall --cask || true
    # keep fish/just/git so this machine still works until you remove them by hand
    brew bundle list --file "$DOTFILES/Brewfile" --formula | grep -vxE 'fish|just|git' |
      xargs -r brew uninstall --ignore-dependencies || true
    brew autoremove
  else
    home-manager uninstall
  fi
}

main "$@"
