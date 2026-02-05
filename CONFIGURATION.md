# Configuration Guide

This document describes all configuration options and hardcoded paths in the dotfiles system.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Configuration Files](#configuration-files)
- [Hardcoded Paths](#hardcoded-paths)
- [Customization](#customization)
- [Directory Structure](#directory-structure)

---

## Environment Variables

### System Updates

#### `SYSTEM_UPDATE_DAYS`
- **Type:** Integer
- **Default:** `7`
- **Description:** Number of days between automatic system updates
- **Usage:** `export SYSTEM_UPDATE_DAYS=14`
- **Used by:** [bin/autoupdate](bin/autoupdate)

#### `SYSTEM_RECEIPT_F`
- **Type:** String (filename)
- **Default:** `.system_lastupdate`
- **Description:** Filename to track last update timestamp (stored in `$HOME`)
- **Usage:** `export SYSTEM_RECEIPT_F=.updatetime`
- **Used by:** [bin/autoupdate](bin/autoupdate)

#### `BASE_URL`
- **Type:** URL string
- **Default:** `https://raw.githubusercontent.com/Gogh-Co/Gogh/master`
- **Description:** Repository URL for color scheme installation
- **Usage:**
  ```bash
  export BASE_URL="https://my-mirror.com/Gogh"
  bash tools/install_gruvbox.sh
  ```
- **Used by:** [tools/install_gruvbox.sh](tools/install_gruvbox.sh)

#### `SET_TERMINAL_COLORS`
- **Type:** Boolean
- **Default:** `true` (on Linux), optional on macOS
- **Description:** Whether to set terminal colors via escape codes
- **Usage:** `export SET_TERMINAL_COLORS=false`
- **Location:** Referenced in `.zshrc`
- **Note:** Set to `false` if using terminal color profiles

#### `BAT_THEME`
- **Type:** String
- **Default:** `gruvbox-dark`
- **Description:** Color theme for `bat` (cat replacement)
- **Usage:** `export BAT_THEME=Monokai Extended`
- **Location:** `.zshrc_local`
- **See:** `bat --list-themes`

#### `OPENAI_API_KEY`
- **Type:** String
- **Description:** OpenAI API key for CodeGPT integration
- **Usage:** `export OPENAI_API_KEY="sk-..."`
- **Location:** `.zshrc_local`
- **Required:** Only for CodeGPT features in Neovim

#### `LANGTOOL_HTTP_URI`
- **Type:** URL
- **Description:** LanguageTool HTTP server URI
- **Usage:** `export LANGTOOL_HTTP_URI="http://localhost:8081"`
- **Location:** `.zshrc_local`
- **Required:** Only for LanguageTool Premium features

#### `LANGTOOL_USERNAME`, `LANGTOOL_API_KEY`
- **Type:** String
- **Description:** LanguageTool authentication credentials
- **Location:** `.zshrc_local`

#### `FAST_WORK_DIR`
- **Type:** Path
- **Default:** `$HOME/.fsh` (auto)
- **Description:** Working directory for Fast Syntax Highlighting zsh plugin
- **Usage:**
  ```bash
  export FAST_WORK_DIR="$HOME/.config/fsh_local"
  fast-theme gruvbox
  ```
- **Location:** `.zshrc_local`

#### `INSULTS_ENABLED`
- **Type:** Boolean
- **Default:** `false`
- **Description:** Enable funny insults when typing invalid commands
- **Usage:** `export INSULTS_ENABLED=true`
- **Location:** `.zshrc_local`

---

## Configuration Files

### Global Configuration Files

These files should **not** be edited directly for personal customizations. Use `*_local` files instead.

| File | Purpose | Type |
|------|---------|------|
| [.vimrc](.vimrc) | Vim/Neovim configuration | Config |
| [.zshrc](.zshrc) | Zsh shell configuration | Shell script |
| [.zprofile](.zprofile) | Zsh login shell config | Shell script |
| [.gitconfig](.gitconfig) | Git configuration | Config |
| [.gitignore](.gitignore) | Global git ignore rules | Config |
| [.tmux.conf](.tmux.conf) | Tmux terminal multiplexer config | Config |
| [.tmux.conf.settings](.tmux.conf.settings) | Tmux theme/style settings | Config |

### Local Override Files

Create these files in your `$HOME` to add personal customizations:

#### `.zshrc_local`
**Purpose:** Add custom shell functions, aliases, and environment variables

**Example:**
```bash
# Custom aliases
alias myalias="command"

# Custom environment variables
export JAVA_HOME="/usr/libexec/java_home"

# Custom functions
myfunction() {
    echo "Custom function"
}
```

#### `.vimrc_local`
**Purpose:** Override vim/neovim settings

**Example:**
```vim
" Custom colorscheme
let g:colorscheme = 'onedark'

" Custom key mappings
nnoremap <leader>w :write<CR>
```

#### `.vimrc_plugins`
**Purpose:** Add additional vim/neovim plugins

**Example:**
```vim
Plug 'my-username/my-plugin'
Plug 'another/plugin', { 'branch': 'develop' }
```

#### `.gitconfig_local`
**Purpose:** Local git user configuration and credentials

**Example:**
```ini
[user]
  name = Your Name
  email = your.email@example.com
[github]
  user = your-github-username
  token = ghp_YourPersonalAccessToken
```

#### `.autoupdate_local.zsh`
**Purpose:** Add custom update commands run during `autoupdate`

**Example:**
```bash
#!/usr/bin/env zsh
echo "Syncing my custom projects..."
cd ~/my-projects && git pull

echo "Running custom build..."
make build
```

#### `.tmux.conf_local`
**Purpose:** Override tmux configuration and key bindings

**Example:**
```tmux
# Custom prefix key
set -g prefix C-a

# Custom key bindings
bind r source-file ~/.tmux.conf
```

#### `.brew_local`
**Purpose:** Install additional Homebrew packages

**Example:**
```bash
brew install my-custom-package
brew tap my-org/packages
brew install my-org/packages/my-package
```

---

## Hardcoded Paths

### Key Paths in Scripts

#### CodeRabbit Organization
```bash
# Default location for CodeRabbit organization repos
$HOME/Work/coderabbitai
```
**Files using this:**
- [bin/sync-coderabbitai](bin/sync-coderabbitai) - Line 14
- Referenced in `autoupdate`

**Can be customized by:**
- Creating a Shell alias that modifies the path
- Creating a personalized sync script in `.autoupdate_local.zsh`

#### FluxNinja Organization
```bash
# Default location for FluxNinja organization repos
$HOME/Work/fluxninja
```
**Files using this:**
- [bin/sync-fluxninja](bin/sync-fluxninja) - Similar to sync-coderabbitai

#### Notes Directory
```bash
# Personal notes directory (used with vale linter)
$HOME/notes
```
**Files using this:**
- [bin/autoupdate](bin/autoupdate) - Line 130

**To customize:**
Add to `.autoupdate_local.zsh`:
```bash
# Override notes directory
export NOTES_DIR="$HOME/my-notes"
```

#### Dotfiles Configuration
```bash
# Dotfiles are stored in a 'sw' symlink or directory
$HOME/sw
```
**Referenced in:**
- [bin/autoupdate](bin/autoupdate) - Lines 116, 119
- Installation script

**Note:** This is typically a symlink to the actual .dotfiles directory managed by chezmoi

#### Zinit (Zsh plugin manager)
```bash
$HOME/.local/share/zinit/zinit.git/zinit.zsh
```
**Files using this:**
- [bin/autoupdate](bin/autoupdate) - Line 108

**To use without zinit:**
Comment out or disable this line in `autoupdate`

#### Local share directory
```bash
$HOME/.local/share
```
**Used for:**
- Zinit plugin manager
- Various application data

---

## Customization

### Modifying Hardcoded Paths

#### Option 1: Create Symlinks

```bash
# If you want to use a different Work directory
mkdir -p ~/projects
ln -s ~/projects/coderabbitai ~/Work/coderabbitai
```

#### Option 2: Modify Scripts Locally

Edit scripts to use your preferred paths:

```bash
# Example: Change default work directory in sync-coderabbitai
sed -i 's|$HOME/Work|$HOME/projects|g' bin/sync-coderabbitai
```

#### Option 3: Create Custom Wrapper Scripts

Create `~/.autoupdate_local.zsh`:

```bash
#!/usr/bin/env zsh

# Custom paths
export WORK_DIR="$HOME/my-work"
export CODERABBITAI_DIR="$WORK_DIR/coderabbitai"

# Custom update function
sync_coderabbitai_custom() {
    gh-clone-all coderabbitai "$CODERABBITAI_DIR"
    pull_all "$CODERABBITAI_DIR"
}
```

### Disabling Specific Updates

In `.autoupdate_local.zsh`, override update commands:

```bash
#!/usr/bin/env zsh

# Disable npm updates
# npm update && npm upgrade && npm audit fix --force && npm prune --production --force

# Disable pip updates
# pip3 install --upgrade pip setuptools wheel && pip3 freeze --local | ...

# Add your own updates instead
echo "Custom update: building project..."
cd ~/projects && make build
```

### Modifying Update Frequency

```bash
# In .zshrc_local or shell profile
export SYSTEM_UPDATE_DAYS=14  # Update every 2 weeks instead of weekly
```

---

## Directory Structure

### Home Directory Layout

```
$HOME/
├── .dotfiles/                    # This repository (or managed by chezmoi)
├── .config/
│   ├── nvim/                    # Neovim config
│   ├── broot/                   # Broot navigator config
│   ├── ghostty/                 # Ghostty terminal config
│   ├── fsh/                     # Fast Syntax Highlighting config
│   └── ...
├── .local/share/
│   └── zinit/                   # Zsh plugin manager
├── Work/
│   ├── coderabbitai/            # CodeRabbit organization repos
│   └── fluxninja/               # FluxNinja organization repos
├── notes/                        # Personal notes (optional)
├── projects/                     # Personal projects (custom)
├── sw/ -> .dotfiles/            # Symlink to dotfiles (optional)
└── [local config files]
    ├── .zshrc_local
    ├── .vimrc_local
    ├── .vimrc_plugins
    ├── .gitconfig_local
    ├── .autoupdate_local.zsh
    ├── .tmux.conf_local
    └── .brew_local
```

### Repository Directory Structure

```
.dotfiles/
├── bin/                         # Executable scripts
│   ├── autoupdate              # Main update script
│   ├── git-ship                # Git commit/push helper
│   ├── pull-all                # Update all repos
│   ├── gh-clone-all            # Clone GitHub org repos
│   └── ... (8+ more scripts)
├── tools/                       # Helper utilities
│   ├── install.sh              # Installation script
│   ├── error-handling.sh       # Error handling library
│   └── ... (other utilities)
├── config/                      # Configuration templates
│   ├── zsh/
│   ├── nvim/
│   ├── git/
│   └── ...
├── assets/                      # Assets and resources
│   ├── images/                 # Documentation images
│   ├── themes/                 # Theme configurations
│   └── wallpapers/             # Wallpaper images
└── vim/                         # Vim plugin configuration
```

---

## Best Practices

### 1. Never Edit Global Config Files Directly
Always use `*_local` files for customizations. This prevents conflicts when updating via chezmoi.

### 2. Version Your Local Configs
Use `vcsh` to version control your `*_local` files:

```bash
vcsh init localconfigs
vcsh localconfigs add ~/.zshrc_local
vcsh localconfigs add ~/.vimrc_local
vcsh localconfigs commit -m "Add local configurations"
```

### 3. Document Custom Paths
If you customize paths, document them in comments:

```bash
# ~/.zshrc_local
# CUSTOM: Using ~/projects instead of ~/Work for development
export WORK_DIR="$HOME/projects"
```

### 4. Use Environment Variables
Prefer environment variables over hardcoding in scripts:

```bash
#!/usr/bin/env bash
WORK_DIR="${WORK_DIR:-$HOME/Work}"
cd "$WORK_DIR" || exit 1
```

### 5. Check Before Modifying
Before customizing, check what the original values are:

```bash
grep -r "Work/coderabbitai" bin/ tools/
```

---

## Troubleshooting Configuration Issues

### "Command not found" when running scripts

Check if paths are set correctly:
```bash
echo $PATH
command -v gh-clone-all
```

### Updates not running on schedule

Check the update receipt file:
```bash
cat ~/.system_lastupdate  # Shows timestamp of last update
```

### Custom paths not being used

Verify environment variables are exported:
```bash
# In .zshrc_local
export MYVAR="value"  # Include 'export'!
```

### Plugins not loading in Neovim

Check plugin paths:
```bash
nvim +PlugStatus
```

---

## Related Documentation

- [README.md](README.md) - Main project documentation
- [SCRIPTS.md](SCRIPTS.md) - Detailed script documentation  
- [tools/error-handling.sh](tools/error-handling.sh) - Error handling library
- [Chezmoi Documentation](https://www.chezmoi.io/) - Dotfile manager

