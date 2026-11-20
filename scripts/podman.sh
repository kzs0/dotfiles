#!/usr/bin/env bash
# Podman as the docker API (for k3d): a rootful VM on macOS, the user socket on
# Linux. The socket path is stored in the fish universal var DOTFILES_PODMAN_SOCK,
# which conf.d/10-env.fish turns into DOCKER_HOST.
. "$(dirname "$0")/lib.sh"

install() {
  command -v podman >/dev/null || { say "missing — Ubuntu: sudo apt install podman · NixOS: virtualisation.podman.enable = true;"; return; }
  local sock
  if is_mac; then
    podman machine inspect >/dev/null 2>&1 || podman machine init --rootful --cpus 4 --memory 8192 --disk-size 60
    [ "$(podman machine inspect --format '{{.State}}')" = running ] || podman machine start
    sock="$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
  else
    systemctl --user enable --now podman.socket
    sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
  fi
  fish -c "set -Ux DOTFILES_PODMAN_SOCK $sock"
  say "socket $sock"
}

remove() {
  confirm "Delete the podman machine and all its containers/images?" || exit 0
  if is_mac; then podman machine stop || true; podman machine rm -f; fi
  fish -c 'set -Ue DOTFILES_PODMAN_SOCK' || true
}

main "$@"
