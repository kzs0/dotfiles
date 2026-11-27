# Shared helpers for scripts/<component>.sh. Each component defines install,
# remove and (optionally) update, then calls `main "$@"`.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPONENT="$(basename "$0" .sh)"
REX_BIN="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
export PATH="$HOME/.local/bin:$HOME/.local/share/npm/bin:$REX_BIN:$PATH"

# What this machine chose in the setup wizard (`just configure`). Machine-local,
# never in the repo. Values already in the environment win over the saved ones.
STATE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/install.env"
STATE_VARS="DOTFILES_COMPONENTS DOTFILES_LANGS DOTFILES_CLOUD DOTFILES_SHORTCUT"
load_state() {
  [ -f "$STATE" ] && . "$STATE"
  export DOTFILES_LANGS="${DOTFILES_LANGS-}" DOTFILES_CLOUD="${DOTFILES_CLOUD-}" DOTFILES_SHORTCUT="${DOTFILES_SHORTCUT-}"
  [ -z "${DOTFILES_COMPONENTS+x}" ] || export DOTFILES_COMPONENTS
}
save_state() {
  mkdir -p "$(dirname "$STATE")"
  { echo "# dotfiles setup choices — written by 'just configure'; edit or re-run it"
    for v in $STATE_VARS; do printf ': "${%s=%s}"\n' "$v" "${!v-}"; done; } > "$STATE"
}
has() { case " $1 " in *" $2 "*) return 0 ;; esac; return 1; }   # has "list" word

is_mac() { [ "$(uname)" = Darwin ]; }
is_nixos() { [ -e /etc/NIXOS ]; }
say() { printf '\033[1;34m%s:\033[0m %s\n' "$COMPONENT" "$*"; }
confirm() {
  [ "${DOTFILES_YES:-}" = 1 ] && return 0
  local a; read -r -p "$1 [y/N] " a </dev/tty || true; [ "$a" = y ] || [ "$a" = Y ]
}
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
