#!/usr/bin/env bash
# Apply Ghostty configuration settings.
# Run standalone or called from setup.sh.

set -euo pipefail

GHOSTTY_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
mkdir -p "$(dirname "$GHOSTTY_CONFIG")"

if ! grep -qF "font-family" "$GHOSTTY_CONFIG" 2>/dev/null; then
  echo "==> Adding Ghostty font-family to config..."
  echo "font-family = MesloLGS Nerd Font" >> "$GHOSTTY_CONFIG"
fi

if ! grep -qF "shell-integration-features" "$GHOSTTY_CONFIG" 2>/dev/null; then
  echo "==> Adding Ghostty shell-integration-features to config..."
  echo "shell-integration-features = ssh-terminfo,ssh-env" >> "$GHOSTTY_CONFIG"
fi

if ! grep -qF "cursor-click-to-move" "$GHOSTTY_CONFIG" 2>/dev/null; then
  echo "==> Adding Ghostty cursor-click-to-move to config..."
  echo "cursor-click-to-move = true" >> "$GHOSTTY_CONFIG"
fi

echo "Ghostty configuration applied to $GHOSTTY_CONFIG"