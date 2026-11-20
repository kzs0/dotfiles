#!/usr/bin/env bash
# fish as the login shell (sudo once, to register it in /etc/shells).
. "$(dirname "$0")/lib.sh"

install() {
  local fish; fish="$(command -v fish)"
  if is_nixos; then say "NixOS: set programs.fish.enable = true; users.users.$USER.shell = pkgs.fish;"; return; fi
  if [ "$(login_shell)" = "$fish" ]; then say "already $fish"; return; fi
  grep -qxF "$fish" /etc/shells || echo "$fish" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$fish" && say "login shell -> $fish"
}

remove() {
  local sh=/bin/bash; is_mac && sh=/bin/zsh
  if is_nixos; then say "NixOS: change users.users.$USER.shell in configuration.nix"; return; fi
  [ "$(login_shell)" = "$sh" ] || chsh -s "$sh" && say "login shell -> $sh"
}

update() { :; }

main "$@"
