#!/usr/bin/env bash
# Rex (macOS): the app, start at login, terminfo, agent skills, and the
# rex-resurrect daemon that resumes pane programs after a server restart.
. "$(dirname "$0")/lib.sh"

DMG=https://blob.superlogical.com/download/rex-app/preview/latest.dmg
LABEL=dev.kzs0.rex-resurrect
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
UNIT="$HOME/.config/systemd/user/rex-resurrect.service"
LOG="$HOME/.local/state/rex-resurrect/daemon.log"

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

install_resurrect() {
  local bin="$HOME/.local/bin/rex-resurrect"
  [ -x "$bin" ] || { say "rex-resurrect not linked — run 'just link bin'"; return 1; }
  mkdir -p "$(dirname "$LOG")"
  if is_mac; then
    cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$bin</string><string>daemon</string></array>
  <key>EnvironmentVariables</key><dict>
    <key>PATH</key><string>$REX_BIN:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict></plist>
PLIST
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
  else
    mkdir -p "$(dirname "$UNIT")"
    printf '[Unit]\nDescription=Resume Rex pane programs after a server restart\n\n[Service]\nExecStart=%s daemon\nRestart=always\nEnvironment=PATH=%s/.local/bin:%s/.nix-profile/bin:/usr/bin:/bin\n\n[Install]\nWantedBy=default.target\n' \
      "$bin" "$HOME" "$HOME" > "$UNIT"
    systemctl --user daemon-reload && systemctl --user enable --now rex-resurrect.service
  fi
  say "rex-resurrect running ('rex-resurrect status' shows what will be resumed)"
}

install() {
  if is_mac; then install_app; login_item; fi
  command -v rex >/dev/null || { say "rex CLI not found — launch Rex once, then 'just setup rex'"; return; }
  rex terminfo setup
  rex skill setup
  rex config check >/dev/null && say "config ok"
  install_resurrect
}

remove() {
  if is_mac; then
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true; rm -f "$PLIST"
  else
    systemctl --user disable --now rex-resurrect.service 2>/dev/null || true; rm -f "$UNIT"
  fi
  say "rex-resurrect removed (the Rex app is left installed)"
}

main "$@"
