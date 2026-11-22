#!/usr/bin/env bash
# The setup wizard and the whole-machine commands behind the justfile:
#   setup.sh install   [--yes] [--reconfigure]   pick components (menu), then install them
#   setup.sh configure                           only re-run the wizard and save the choices
#   setup.sh update                              update the components this machine chose
#   setup.sh uninstall [--yes]                   pick what to remove (menu), then remove it
# --yes (or DOTFILES_YES=1, or no terminal) skips the questions: saved choices, else defaults.
. "$(dirname "$0")/lib.sh"
. "$(dirname "$0")/menu.sh"
load_state

S="$DOTFILES/scripts"
ORDER="packages fish nvim shell agents langs headroom rex podman shortcut macos"   # install order
LANG_DEFAULTS="python=3.13 go=latest node=lts rust=stable"
DEFAULT_LANGS="python@3.13 go@latest"
DEFAULT_SHORTCUT=dots

for a in "$@"; do case "$a" in -y | --yes | yes) DOTFILES_YES=1 ;; esac; done
export DOTFILES_YES="${DOTFILES_YES:-}"
interactive() { [ "$DOTFILES_YES" != 1 ] && has_tty; }

default_components() { echo "packages fish nvim shell agents headroom $(is_mac && echo rex) podman"; }

# checked state for a menu item: from the saved choice if there is one, else the default
chk() { if [ -n "${DOTFILES_COMPONENTS+x}" ]; then has "$DOTFILES_COMPONENTS" "$1" && echo 1 || echo 0; else echo "$2"; fi; }

lang_default() { local p; for p in $LANG_DEFAULTS; do [ "${p%%=*}" = "$1" ] && echo "${p#*=}"; done; return 0; }
lang_saved() { local s out=''; for s in $DOTFILES_LANGS; do [ "${s%%@*}" = "$1" ] && out="$out ${s#*@}"; done; echo "${out# }"; }
lang_chk() {
  if [ -n "${DOTFILES_COMPONENTS+x}" ]; then [ -n "$(lang_saved "$1")" ] && echo 1 || echo 0
  else local d; for d in $DEFAULT_LANGS; do [ "${d%%@*}" = "$1" ] && { echo 1; return; }; done; echo 0; fi
}

wizard() {
  local comps langs cloud specs='' l v versions name
  echo; printf '\033[1mdotfiles setup\033[0m — %s\n\n' "$(is_mac && echo macOS || echo Linux)"

  local items; items=(
    "packages|Packages: CLI tools and apps ($(is_mac && echo Brewfile || echo 'Home Manager'))|$(chk packages 1)"
    "fish|fish plugins + tide prompt|$(chk fish 1)"
    "shell|fish as the login shell (sudo once)|$(chk shell 1)"
    "nvim|Neovim plugins (LazyVim, pinned)|$(chk nvim 1)"
    "agents|Coding agents: claude, codex, pi|$(chk agents 1)"
    "headroom|Headroom compression proxy for the agents|$(chk headroom 1)"
    "rex|Rex terminal app + rex-resurrect|$(chk rex "$(is_mac && echo 1 || echo 0)")"
    "podman|Podman socket for k3d|$(chk podman 1)"
  )
  is_mac && items+=("macos|macOS defaults (key repeat, Finder, Dock)|$(chk macos 0)")
  comps="$(multiselect "Components" "${items[@]}")" || exit 130
  echo

  langs="$(multiselect "Languages (managed by mise; pick versions next)" \
    "python|Python|$(lang_chk python)" "go|Go|$(lang_chk go)" \
    "node|Node.js|$(lang_chk node)" "rust|Rust|$(lang_chk rust)")" || exit 130
  for l in $langs; do
    v="$(lang_saved "$l")"; [ -n "$v" ] || v="$(lang_default "$l")"
    versions="$(ask "  $l versions, space-separated (first is the default):" "$v")"
    for v in $versions; do
      case "$v" in *[!A-Za-z0-9._-]*) say "skipping odd version '$v'"; continue ;; esac
      specs="$specs $l@$v"
    done
  done
  echo

  cloud="$(multiselect "Cloud CLIs" \
    "gcloud|Google Cloud (gcloud)|$(has "$DOTFILES_CLOUD" gcloud && echo 1 || echo 0)" \
    "aws|AWS (aws)|$(has "$DOTFILES_CLOUD" aws && echo 1 || echo 0)" \
    "azure|Azure (az)|$(has "$DOTFILES_CLOUD" azure && echo 1 || echo 0)")" || exit 130
  if [ -n "$cloud" ] && ! has "$comps" packages; then
    say "cloud CLIs come from the package list, so 'packages' is on too"; comps="packages $comps"
  fi
  echo

  while :; do
    name="$(ask "Command to run dotfiles recipes from any directory ('none' to skip):" "${DOTFILES_SHORTCUT:-$DEFAULT_SHORTCUT}")"
    case "$name" in
      none | -) name=''; break ;;
      [A-Za-z_]*) case "$name" in *[!A-Za-z0-9_-]*) ;; *) break ;; esac ;;
    esac
    echo "  letters, digits, - and _ only" >/dev/tty
  done

  [ -n "${specs# }" ] && comps="$comps langs"
  [ -n "$name" ] && comps="$comps shortcut"
  DOTFILES_COMPONENTS="$(ordered "$comps")"; DOTFILES_LANGS="${specs# }"; DOTFILES_CLOUD="$cloud"; DOTFILES_SHORTCUT="$name"
  summary
  yesno "Save these choices?" || exit 130
  save_state
  say "saved to $STATE"
}

ordered() { local c out=''; for c in $ORDER; do has "$1" "$c" && out="$out $c"; done; echo "${out# }"; }

summary() {
  printf '\n  components  %s\n  languages   %s\n  cloud CLIs  %s\n  command     %s\n\n' \
    "${DOTFILES_COMPONENTS:-none}" "${DOTFILES_LANGS:-none}" "${DOTFILES_CLOUD:-none}" "${DOTFILES_SHORTCUT:-dotfiles}"
}

choose() {
  if [ -n "${DOTFILES_COMPONENTS+x}" ] && [ "${1:-}" != --reconfigure ]; then
    if interactive && [ -f "$STATE" ]; then
      summary
      yesno "Use these saved choices? (no opens the wizard)" && return
      wizard
    fi
    return
  fi
  if interactive; then wizard; return; fi
  DOTFILES_COMPONENTS="$(ordered "$(default_components) langs shortcut")"
  [ -n "$DOTFILES_LANGS" ] || DOTFILES_LANGS="$DEFAULT_LANGS"
  DOTFILES_SHORTCUT="${DOTFILES_SHORTCUT:-$DEFAULT_SHORTCUT}"
  save_state; say "no saved choices: using the defaults (just configure to pick)"; summary
}

run() {   # run ACTION over the chosen components, in order
  local c
  export DOTFILES_COMPONENTS DOTFILES_LANGS DOTFILES_CLOUD DOTFILES_SHORTCUT
  for c in $DOTFILES_COMPONENTS; do
    printf '\n\033[1;34m==> %s %s\033[0m\n' "$1" "$c"
    "$S/$c.sh" "$1"
  done
}

install() {
  local reconf=''; for a in "$@"; do [ "$a" = --reconfigure ] && reconf=--reconfigure; done
  choose $reconf
  run install
  echo
  say "done. Next: 'just auth', 'just git-identity \"Name\" email', then open a new terminal."
  has "$DOTFILES_CLOUD" gcloud && say "gcloud: run 'gcloud init'"
  has "$DOTFILES_CLOUD" aws && say "aws: run 'aws configure sso' (or 'aws configure')"
  has "$DOTFILES_CLOUD" azure && say "azure: run 'az login'"
  return 0
}

configure() { interactive || { say "needs a terminal"; exit 1; }; wizard; say "run 'just install' to apply"; }

update() {
  [ -n "${DOTFILES_COMPONENTS+x}" ] || DOTFILES_COMPONENTS="$(default_components)"
  run update
}

uninstall() {
  local installed chosen c rest='' items; items=()
  installed="${DOTFILES_COMPONENTS-$(default_components)}"
  if interactive; then
    echo
    for c in $ORDER; do
      case "$c" in macos) is_mac || continue ;; esac
      has "$installed" "$c" || continue
      items+=("$c|$c$(describe "$c")|1")
    done
    items+=("configs|config symlinks (originals are in ~/.dotfiles-backup)|1")
    chosen="$(multiselect "Remove what? (packages and podman ask again before deleting)" "${items[@]}")" || exit 130
  else
    chosen="$installed configs"
  fi
  [ -n "$chosen" ] || { say "nothing selected"; return; }

  # reverse install order, so packages (and fish/just) go last
  local rev=''; for c in $ORDER; do rev="$c $rev"; done
  export DOTFILES_COMPONENTS DOTFILES_LANGS DOTFILES_CLOUD DOTFILES_SHORTCUT
  for c in $rev; do
    has "$chosen" "$c" || continue
    printf '\n\033[1;34m==> remove %s\033[0m\n' "$c"
    "$S/$c.sh" remove || say "$c: remove failed, continuing"
  done
  if has "$chosen" configs; then printf '\n\033[1;34m==> unlink configs\033[0m\n'; "$S/link.sh" unlink; fi

  for c in $installed; do has "$chosen" "$c" || rest="$rest $c"; done
  if [ -z "${rest# }" ]; then rm -f "$STATE"; rmdir "$(dirname "$STATE")" 2>/dev/null || true
  else
    has "$chosen" langs && DOTFILES_LANGS=''
    has "$chosen" shortcut && DOTFILES_SHORTCUT=''
    DOTFILES_COMPONENTS="${rest# }"; save_state
  fi
  echo; say "done. Open a new terminal. The repo itself is still at $DOTFILES (rm -rf it to finish)."
}

describe() {
  case "$1" in
    packages) echo " — every package from the $(is_mac && echo Brewfile || echo 'Home Manager profile') (keeps fish, just, git)" ;;
    shell) echo " — back to $(is_mac && echo zsh || echo bash)" ;;
    langs) echo " — ${DOTFILES_LANGS:-mise tools}" ;;
    shortcut) echo " — the '${DOTFILES_SHORTCUT:-?}' command" ;;
    podman) echo " — deletes the VM, containers and images" ;;
  esac
}

main "$@"
