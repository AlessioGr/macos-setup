#!/usr/bin/env bash
# Apply macOS system preferences (defaults).
# Run this after a fresh install or to restore your preferred settings.
# Some changes require logging out or restarting the Dock/Finder to take effect.

set -euo pipefail

echo "==> Applying macOS settings..."

# --- Dock ---
# Auto-hide: on
defaults write com.apple.dock autohide -bool true
# Delay before showing/hiding (seconds). 0 = minimal delay
defaults write com.apple.dock "autohide-delay" -float 0
# Animation speed (lower = faster). 0.4 = snappy
defaults write com.apple.dock "autohide-time-modifier" -float 0.4
# Minimize effect: scale | genie
defaults write com.apple.dock mineffect -string "scale"
# Minimize windows into application icon
defaults write com.apple.dock "minimize-to-application" -bool true
# Icon size (pixels)
defaults write com.apple.dock tilesize -int 59

# --- Keyboard (NSGlobalDomain) ---
# Key repeat speed (2 = fast; 1–120, lower is faster)
defaults write NSGlobalDomain KeyRepeat -int 2
# Delay until repeat (ms). 15 = short delay
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- General ---
# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 24-hour time
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
# Double-click window title bar: Fill = zoom/fit (other: Maximize, Minimize, None)
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Fill"
# Auto switch between light/dark by time of day
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# --- Terminal.app ---
# Set font to Nerd Font for oh-my-posh icons
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "MesloLGL Nerd Font Mono"'

# --- Default Browser ---
# Vivaldi is Chromium-based, so we can use its built-in flag
open -a "Vivaldi" --args --make-default-browser

# --- Restart Dock so Dock changes apply ---
killall Dock 2>/dev/null || true

echo "==> Done. Dock has been restarted; other settings apply immediately (or after logout)."
