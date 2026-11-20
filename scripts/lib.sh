# Shared helpers for scripts/<component>.sh. Each component defines install,
# remove and (optionally) update, then calls `main "$@"`.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPONENT="$(basename "$0" .sh)"
REX_BIN="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
export PATH="$HOME/.local/bin:$HOME/.local/share/npm/bin:$REX_BIN:$PATH"

is_mac() { [ "$(uname)" = Darwin ]; }
is_nixos() { [ -e /etc/NIXOS ]; }
say() { printf '\033[1;34m%s:\033[0m %s\n' "$COMPONENT" "$*"; }
confirm() { read -r -p "$1 [y/N] " a; [ "$a" = y ] || [ "$a" = Y ]; }
login_shell() {
  if is_mac; then dscl . -read ~/ UserShell | awk '{print $2}'; else getent passwd "$USER" | cut -d: -f7; fi
}

main() {
  local cmd="${1:-install}"
  [ "$cmd" = update ] && ! declare -F update >/dev/null && cmd=install
  declare -F "$cmd" >/dev/null || { echo "usage: $0 install|remove|update" >&2; exit 2; }
  shift || true
  "$cmd" "$@"
}
