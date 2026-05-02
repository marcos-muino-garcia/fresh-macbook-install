#!/usr/bin/env bash
# Sane macOS defaults. Cherry-picked from Mathias Bynens' famous .macos
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
set -euo pipefail

# ----- Screenshots --------------------------------------------------------
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture show-thumbnail -bool true
defaults write com.apple.screencapture include-date -bool true
defaults write com.apple.screencapture type -string "png"

# ----- Keyboard -----------------------------------------------------------
# Faster key repeat (lower is faster). Defaults: KeyRepeat=6, Initial=25.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable press-and-hold for keys in favor of key repeat (so vim/JetBrains feel right).
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Disable smart quotes/dashes/auto-correct (they fight with code).
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ----- Trackpad -----------------------------------------------------------
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ----- Finder -------------------------------------------------------------
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Default to list view in Finder windows.
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Avoid creating .DS_Store files on network and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ----- Dock ---------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
# Don't reorder Spaces by most-recent-use (keeps muscle memory stable).
defaults write com.apple.dock mru-spaces -bool false

# ----- Network ------------------------------------------------------------
# Show all interfaces in Bonjour browser (handy for remote dev).
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# ----- Apply --------------------------------------------------------------
killall Finder Dock SystemUIServer >/dev/null 2>&1 || true
