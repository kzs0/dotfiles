#!/usr/bin/env bash
# Neovim plugins, pinned in config/nvim/lazy-lock.json.
. "$(dirname "$0")/lib.sh"

install() { nvim --headless "+Lazy! restore" +qa; }

# bump plugins and rewrite the lockfile in the repo (commit it)
update() {
  nvim --headless "+Lazy! sync" +qa
  git -C "$DOTFILES" diff --stat config/nvim/lazy-lock.json
}

remove() { rm -rf ~/.local/share/nvim/lazy ~/.local/share/nvim/mason && say "removed plugins"; }

main "$@"
