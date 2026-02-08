# macOS Setup

One-shot setup for a fresh MacBook: install Xcode CLI tools, Homebrew, everything defined in the Brewfile (CLI tools, GUI apps, VS Code extensions) and MacOS settings.

## Quick start

```bash
./setup.sh
```

**Note:** If Xcode Command Line Tools are not installed, the script will open the installer. Finish that, then run `./setup.sh` again.

## What gets installed

- **Homebrew** (if missing)
- Everything in **`brew/Brewfile`**: taps, formulae, casks, and VS Code extensions
- MacOS settings

Edit `brew/Brewfile` to add or remove packages, then run `./setup.sh` again (or `brew bundle --file=brew/Brewfile`) to sync.

## Requirements

- macOS
- Network access (for Homebrew and installers)
