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

# Ensure Homebrew shellenv is in .zprofile (puts /opt/homebrew/bin on PATH)
if ! grep -qF "brew shellenv" ~/.zprofile 2>/dev/null; then
  echo "==> Adding Homebrew to ~/.zprofile..."
  echo '' >> ~/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
fi

echo "==> Installing from Brewfile..."
brew bundle --file="${BREW_DIR}/Brewfile"

# mise: activate in .zshrc if not already present
if ! grep -qF "mise activate zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding mise to ~/.zshrc..."
  echo '' >> ~/.zshrc
  echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
fi

# zsh-autocomplete: source the plugin in .zshrc if not already present
ZSH_AC_LINE='source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"'
if ! grep -qF "zsh-autocomplete.plugin.zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding zsh-autocomplete to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# zsh-autocomplete" >> ~/.zshrc
  echo "$ZSH_AC_LINE" >> ~/.zshrc
fi

# oh-my-posh: initialize prompt in .zshrc if not already present
OMP_LINE='eval "$(oh-my-posh init zsh)"'
if ! grep -qF "oh-my-posh init zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding oh-my-posh to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# oh-my-posh" >> ~/.zshrc
  echo "$OMP_LINE" >> ~/.zshrc
fi

# Fix beam cursor (oh-my-posh resets it to a block)
if ! grep -qF "_fix_cursor" ~/.zshrc 2>/dev/null; then
  echo "==> Adding beam cursor fix to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# Fix beam cursor (oh-my-posh resets it to block)" >> ~/.zshrc
  echo '_fix_cursor() { echo -ne '\''\e[5 q'\'' }' >> ~/.zshrc
  echo 'precmd_functions+=(_fix_cursor)' >> ~/.zshrc
fi

# zsh-syntax-highlighting: source the plugin in .zshrc if not already present
# NOTE: must be the last plugin sourced in .zshrc
ZSH_SH_LINE='source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"'
if ! grep -qF "zsh-syntax-highlighting.zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding zsh-syntax-highlighting to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# zsh-syntax-highlighting (must be last plugin sourced)" >> ~/.zshrc
  echo "$ZSH_SH_LINE" >> ~/.zshrc
fi

# Cursor: apply user settings (merges into existing settings.json)
CURSOR_SETTINGS="$HOME/Library/Application Support/Cursor/User/settings.json"
CURSOR_DESIRED="${SCRIPT_DIR}/cursor/settings.json"
echo "==> Applying Cursor user settings..."
mkdir -p "$(dirname "$CURSOR_SETTINGS")"
[[ -f "$CURSOR_SETTINGS" ]] || echo '{}' > "$CURSOR_SETTINGS"
# Strip JSONC trailing commas in JS, then merge desired keys into existing
MERGED=$(osascript -l JavaScript -e "
  function parseJsonc(s) { return JSON.parse(s.replace(/,\s*([}\]])/g, '\$1')); }
  var existing = parseJsonc(\`$(cat "$CURSOR_SETTINGS")\`);
  var desired  = parseJsonc(\`$(cat "$CURSOR_DESIRED")\`);
  Object.assign(existing, desired);
  JSON.stringify(existing, null, 2);
")
echo "$MERGED" > "$CURSOR_SETTINGS"

# Ghostty: set Nerd Font if config doesn't exist yet
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
  echo "==> Creating Ghostty config with Nerd Font..."
  mkdir -p "$(dirname "$GHOSTTY_CONFIG")"
  echo "font-family = MesloLGS Nerd Font" > "$GHOSTTY_CONFIG"
fi

if [[ -x "${SCRIPT_DIR}/macos/settings.sh" ]]; then
  echo ""
  "${SCRIPT_DIR}/macos/settings.sh"
fi

echo ""
echo "==> Setup complete. Restart the terminal or run \`source ~/.zprofile\` if needed."
