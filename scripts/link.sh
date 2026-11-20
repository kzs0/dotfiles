#!/usr/bin/env bash
# Symlink files from ./config/<pkg>/ into ~/.config/<pkg>/, file by file.
# A package with a `.link-target` file (a path relative to $HOME, e.g. `.pi/agent`)
# links into that directory instead.
# Linking file-by-file (not whole dirs) keeps tool-generated files (fisher plugins,
# fish_variables, zed state…) out of the repo.
#
#   link.sh link   <pkg>...   create links (existing real files are backed up)
#   link.sh unlink <pkg>...   remove links that point into this repo
#   link.sh status <pkg>...   show link state
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

cmd="${1:?usage: link.sh link|unlink|status <pkg>...}"; shift
[ $# -gt 0 ] || set -- $(ls "$DOTFILES/config")

for pkg in "$@"; do
  src_root="$DOTFILES/config/$pkg"
  [ -d "$src_root" ] || { echo "no such package: $pkg" >&2; exit 1; }
  if [ -f "$src_root/.link-target" ]; then dst_root="$HOME/$(cat "$src_root/.link-target")"
  else dst_root="$TARGET/$pkg"; fi
  while IFS= read -r -d '' src; do
    rel="$pkg/${src#"$src_root/"}"
    dst="$dst_root/${src#"$src_root/"}"
    case "$cmd" in
      link)
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then continue; fi
        if [ -e "$dst" ] || [ -L "$dst" ]; then
          mkdir -p "$BACKUP/$(dirname "$rel")"
          mv "$dst" "$BACKUP/$rel"
          echo "  backed up $dst -> $BACKUP/$rel"
        fi
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        echo "  linked $dst"
        ;;
      unlink)
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
          rm "$dst"; echo "  removed $dst"
        fi
        ;;
      status)
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then s="ok"
        elif [ -e "$dst" ]; then s="CONFLICT (real file)"
        else s="missing"; fi
        printf '  %-10s %s\n' "$s" "$dst"
        ;;
      *) echo "unknown command: $cmd" >&2; exit 1 ;;
    esac
  done < <(find "$src_root" -type f ! -name '.DS_Store' ! -name '.link-target' -print0)
done

# machine-local git config (identity, credential helpers) lives outside the repo
[ "$cmd" = link ] && touch "$HOME/.gitconfig"
exit 0
