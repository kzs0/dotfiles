#!/usr/bin/env bash
# Rex (macOS): the app, start at login, terminfo and agent skills. Rex resumes
# pane programs after a server restart itself (this used to be rex-resurrect;
# `just rex-resurrect-cleanup` removes that daemon from older machines).
. "$(dirname "$0")/lib.sh"

DMG=https://blob.superlogical.com/download/rex-app/preview/latest.dmg

install_app() {
  ls -d /Applications/Rex*.app >/dev/null 2>&1 && return
  say "downloading Rex…"
  local tmp mnt; tmp="$(mktemp -d)"; curl -fsSL -o "$tmp/rex.dmg" "$DMG"
  mnt="$(hdiutil attach -nobrowse -readonly "$tmp/rex.dmg" | awk -F'\t' '/\/Volumes\//{print $NF}')"
  cp -R "$mnt"/Rex*.app /Applications/; hdiutil detach -quiet "$mnt"; rm -rf "$tmp"
  open -a "$(basename /Applications/Rex*.app .app)"; sleep 5   # first launch installs the CLI
}

# Rex can't start its server at boot on macOS yet; opening the app at login does
login_item() {
  local app; app="$(ls -d /Applications/Rex*.app | head -1)"
  osascript -e 'tell application "System Events" to get the path of every login item' 2>/dev/null | grep -q "$app" ||
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$app\", hidden:true}" >/dev/null
}

install() {
  "$DOTFILES/scripts/rex-resurrect-cleanup.sh" --quiet   # TEMPORARY: drop the old daemon if it's still here
  if is_mac; then install_app; login_item; fi
  command -v rex >/dev/null || { say "rex CLI not found — launch Rex once, then 'just setup rex'"; return; }
  rex terminfo setup
  rex skill setup
  if rex config check >/dev/null; then say "config ok"; else say "rex config check failed — run it to see why"; fi
}

remove() {
  if is_mac; then
    osascript -e 'tell application "System Events" to delete (every login item whose path contains "/Rex")' >/dev/null 2>&1 || true
  fi
  say "removed the login item (the Rex app, terminfo and skills are left installed)"
}

main "$@"
