#!/usr/bin/env bash
# Language toolchains via mise (python, go, node, rust…). The versions come from
# the setup wizard (DOTFILES_LANGS, e.g. "python@3.13 python@3.12 go@latest") and
# land in mise's global config, ~/.config/mise/config.toml (machine-local).
. "$(dirname "$0")/lib.sh"
load_state

export MISE_YES=1
APPLIED="$(dirname "$STATE")/langs.applied"   # what we last put in mise's config

need_mise() { command -v mise >/dev/null || { say "mise missing — it comes from the Brewfile / nix profile ('just setup packages')"; exit 1; }; }

install() {
  need_mise
  local s gone=''
  # drop tools we added before that are no longer picked (leave the rest of the user's mise config alone)
  if [ -f "$APPLIED" ]; then
    for s in $(cat "$APPLIED"); do has "$DOTFILES_LANGS" "$s" || gone="$gone $s"; done
    [ -z "${gone# }" ] || mise unuse -g $gone
  fi
  if [ -z "$DOTFILES_LANGS" ]; then say "no languages picked ('just configure')"; rm -f "$APPLIED"; return; fi
  mise use -g $DOTFILES_LANGS
  mkdir -p "$(dirname "$APPLIED")"; echo "$DOTFILES_LANGS" > "$APPLIED"
  mise ls --global --current 2>/dev/null || true
}

# newest patch/minor within each picked version (e.g. 3.13 -> latest 3.13.x)
update() { need_mise; mise upgrade || true; install; }

remove() {
  need_mise
  local specs="${DOTFILES_LANGS}"; [ -f "$APPLIED" ] && specs="$(cat "$APPLIED")"
  [ -z "$specs" ] || mise unuse -g $specs
  rm -f "$APPLIED"
  say "removed $specs"
}

main "$@"
