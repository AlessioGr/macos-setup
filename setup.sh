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

# mise: install latest Node LTS globally. Node needs to be installed globally for cursor MCP
# servers that use `npx` to work.
echo "==> Installing Node LTS via mise..."
mise use --global node@lts

# mise: activate in .zshrc if not already present
if ! grep -qF "mise activate zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding mise to ~/.zshrc..."
  echo '' >> ~/.zshrc
  echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
fi

# Husky: disable git hooks globally.
# Set in .zshenv (sourced by all zsh invocations) and via launchctl (so GUI apps
# like Cursor/VS Code that spawn git directly without a shell also see it).
if ! grep -qF "HUSKY=0" ~/.zshenv 2>/dev/null; then
  echo "==> Disabling Husky git hooks in ~/.zshenv..."
  echo 'export HUSKY=0' >> ~/.zshenv
fi
echo "==> Setting HUSKY=0 at macOS session level..."
launchctl setenv HUSKY 0

# zsh-autocomplete: source the plugin in .zshrc if not already present
ZSH_AC_LINE='source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"'
if ! grep -qF "zsh-autocomplete.plugin.zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding zsh-autocomplete to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# zsh-autocomplete" >> ~/.zshrc
  echo "$ZSH_AC_LINE" >> ~/.zshrc
fi

# oh-my-posh: install config and initialize prompt in .zshrc
OMP_CONFIG_DIR="$HOME/.config/ohmyposh"
OMP_CONFIG="$OMP_CONFIG_DIR/config.json"
echo "==> Installing oh-my-posh config..."
mkdir -p "$OMP_CONFIG_DIR"
cp "${SCRIPT_DIR}/ohmyposh.json" "$OMP_CONFIG"

OMP_LINE='eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/config.json)"'
if ! grep -qF "oh-my-posh init zsh" ~/.zshrc 2>/dev/null; then
  echo "==> Adding oh-my-posh to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# oh-my-posh" >> ~/.zshrc
  echo "$OMP_LINE" >> ~/.zshrc
elif ! grep -qF -- "--config" ~/.zshrc 2>/dev/null; then
  echo "==> Updating oh-my-posh line in ~/.zshrc to use custom config..."
  sed -i '' 's|eval "$(oh-my-posh init zsh)"|eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/config.json)"|' ~/.zshrc
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

# Cursor: apply user keybindings
CURSOR_KEYBINDINGS="$HOME/Library/Application Support/Cursor/User/keybindings.json"
CURSOR_DESIRED_KB="${SCRIPT_DIR}/cursor/keybindings.json"
if [[ -f "$CURSOR_DESIRED_KB" ]]; then
  echo "==> Applying Cursor keybindings..."
  cp "$CURSOR_DESIRED_KB" "$CURSOR_KEYBINDINGS"
fi

# VS Code: apply user keybindings
VSCODE_KEYBINDINGS="$HOME/Library/Application Support/Code/User/keybindings.json"
if [[ -f "$CURSOR_DESIRED_KB" ]]; then
  echo "==> Applying VS Code keybindings..."
  mkdir -p "$(dirname "$VSCODE_KEYBINDINGS")"
  cp "$CURSOR_DESIRED_KB" "$VSCODE_KEYBINDINGS"
fi

# Claude Code: apply user settings
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_DESIRED="${SCRIPT_DIR}/claude/settings.json"
if [[ -f "$CLAUDE_DESIRED" ]]; then
  echo "==> Applying Claude Code settings..."
  mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
  cp "$CLAUDE_DESIRED" "$CLAUDE_SETTINGS"
fi

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
