#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_DIR="${SCRIPT_DIR}/brew"

echo "==> macOS setup (macos-setup)"
echo ""

# Xcode Command Line Tools (required for Homebrew and many dev tools)
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools (required for Homebrew)..."
  xcode-select --install
  echo "Please complete the Xcode CLI install in the dialog, then run this script again."
  exit 0
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon (common on fresh installs)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "==> Installing from Brewfile..."
brew bundle --file="${BREW_DIR}/Brewfile"

if [[ -x "${SCRIPT_DIR}/macos/settings.sh" ]]; then
  echo ""
  "${SCRIPT_DIR}/macos/settings.sh"
fi

echo ""
echo "==> Setup complete. Restart the terminal or run \`source ~/.zprofile\` if needed."
