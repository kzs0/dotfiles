#!/usr/bin/env bash
# Coding agents: claude (native installer), codex (Brewfile / nix), pi (npm).
. "$(dirname "$0")/lib.sh"

PI=@mariozechner/pi-coding-agent
NPM=(npm --prefix "$HOME/.local/share/npm")

install() {
  command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
  command -v pi >/dev/null || "${NPM[@]}" install -g "$PI"
  command -v codex >/dev/null || say "codex missing — it comes from the Brewfile / nix profile"
  say "claude $(claude --version 2>/dev/null | head -1) · codex $(codex --version 2>/dev/null) · pi $(pi --version 2>&1)"
}

update() {
  claude update || true
  "${NPM[@]}" update -g "$PI"
  install
}

remove() { "${NPM[@]}" uninstall -g "$PI" || true; say "removed pi (claude: rm ~/.local/bin/claude)"; }

main "$@"
