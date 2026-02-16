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

## Manual steps

These can't be automated and need to be done after running the setup script:

1. **Raycast — set Ghostty as "Terminal"**
   - Open Raycast Settings (`Cmd + ,`) > Extensions > Applications
   - Disable **Terminal**
   - Set alias `terminal` on **Ghostty**

2. **Raycast — set OrbStack as "Docker"**
   - Open Raycast Settings (`Cmd + ,`) > Extensions > Applications
   - Set alias `docker` on **OrbStack**

## Requirements

- macOS
- Network access (for Homebrew and installers)
