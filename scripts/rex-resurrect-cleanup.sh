#!/usr/bin/env bash
# TEMPORARY — delete this file (and its justfile recipe and the call in rex.sh) once
# every machine has run it. Rex now resumes pane programs after a server restart on
# its own, so the old rex-resurrect daemon is redundant (and would resume things twice).
#
# Removes, if present: the launchd agent (macOS) or systemd user service (Linux),
# the running daemon, the ~/.local/bin/rex-resurrect link, and its state/log dir.
#   rex-resurrect-cleanup.sh [--quiet]   (--quiet: say nothing when there was nothing to do)
. "$(dirname "$0")/lib.sh"

LABEL=dev.kzs0.rex-resurrect
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
UNIT="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/rex-resurrect.service"
BIN="$HOME/.local/bin/rex-resurrect"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/rex-resurrect"

done_any=0
did() { done_any=1; say "$*"; }

cleanup() {
  if is_mac; then
    if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
      launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true; did "stopped launchd agent $LABEL"
    fi
    [ -e "$PLIST" ] && { rm -f "$PLIST"; did "removed $PLIST"; }
  elif command -v systemctl >/dev/null; then
    if systemctl --user cat rex-resurrect.service >/dev/null 2>&1; then
      systemctl --user disable --now rex-resurrect.service >/dev/null 2>&1 || true; did "stopped systemd user service rex-resurrect"
    fi
    if [ -e "$UNIT" ]; then rm -f "$UNIT"; systemctl --user daemon-reload 2>/dev/null || true; did "removed $UNIT"; fi
  fi
  # a daemon started by hand (not by launchd/systemd)
  if pkill -f 'rex-resurrect daemon' 2>/dev/null; then did "stopped a running rex-resurrect daemon"; fi
  # the link into this repo (now dangling); leave a real file alone, it isn't ours
  if [ -L "$BIN" ]; then rm -f "$BIN"; did "removed $BIN"
  elif [ -e "$BIN" ]; then say "left $BIN alone (not a symlink — delete it yourself if it's the old daemon)"; fi
  [ -d "$STATE_DIR" ] && { rm -rf "$STATE_DIR"; did "removed $STATE_DIR (snapshots + log)"; }

  if [ "$done_any" = 0 ]; then
    [ "${1:-}" = --quiet ] || say "nothing to clean up — rex-resurrect isn't on this machine"
  else
    say "done. Rex's built-in restore takes over from here."
  fi
}

main cleanup "$@"
