#!/usr/bin/env bash
# Rex: start at login (macOS), terminfo and agent skills. Install the app
# yourself first; this doesn't download it. Rex resumes pane programs after a
# server restart itself (this used to be rex-resurrect; `just rex-resurrect-cleanup`
# removes that daemon from older machines).
. "$(dirname "$0")/lib.sh"

# Rex can't start its server at boot on macOS yet; opening the app at login does
login_item() {
  local app; app="$(ls -d /Applications/Rex*.app | head -1)"
  osascript -e 'tell application "System Events" to get the path of every login item' 2>/dev/null | grep -q "$app" ||
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$app\", hidden:true}" >/dev/null
}

install() {
  "$DOTFILES/scripts/rex-resurrect-cleanup.sh" --quiet   # TEMPORARY: drop the old daemon if it's still here
  if is_mac; then
    if ls -d /Applications/Rex*.app >/dev/null 2>&1; then login_item
    else say "Rex app not in /Applications — install it yourself, open it once, then 'just setup rex'"; return; fi
  fi
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
