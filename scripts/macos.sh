#!/usr/bin/env bash
# Optional macOS defaults: off by default in the `just install` wizard, or `just setup macos`.
. "$(dirname "$0")/lib.sh"

install() {
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.screencapture location -string "$HOME/Desktop"
  killall Finder Dock SystemUIServer || true
  say "done (some settings need a logout)"
}

remove() { say "nothing to undo automatically — change these in System Settings"; }

main "$@"
