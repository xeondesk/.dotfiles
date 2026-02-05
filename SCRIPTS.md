# Available Scripts

This document describes all the scripts available in this dotfiles repository.

## Table of Contents

- [bin/ - Executable Scripts](#bin---executable-scripts)
- [tools/ - Helper Scripts](#tools---helper-scripts)

---

## bin/ - Executable Scripts

These scripts are meant to be executed directly from the command line.

### autoupdate

**Description:** Updates the entire system including dotfiles, shell plugins, nvim, npm, pip, and other tools.

**Usage:**
```bash
autoupdate              # Update if 7 days have passed since last update
autoupdate --force      # Force update regardless of time interval
```

**Features:**
- Automatic interval checking (configurable via `$SYSTEM_UPDATE_DAYS`)
- Updates chezmoi dotfiles
- Sources custom local autoupdate file (`~/.autoupdate_local.zsh`)
- Updates shell plugin manager (zinit)
- Updates Neovim and plugins
- Updates npm packages globally
- Updates pip packages
- Updates tldr database
- Syncs notes with vale
- Syncs CodeRabbit and FluxNinja repositories

**Environment Variables:**
- `SYSTEM_UPDATE_DAYS` - Days between updates (default: 7)
- `SYSTEM_RECEIPT_F` - File to track last update (default: `.system_lastupdate`)

**Dependencies:**
- `chezmoi` - Dotfile manager
- `revolver` - Progress spinner
- `tput` - Terminal control
- `zinit` - Zsh plugin manager (optional)
- `npm`, `pip3` - Package managers
- `tldr` - Command documentation
- `vale` - Natural language linting

---

### git-ship

**Description:** Interactively commit and push changes to git with automatic message suggestions and retry logic.

**Usage:**
```bash
git-ship                    # Interactive mode - choose commit type and write message
git-ship "fix: bug fix"     # Use provided commit message directly
git-ship --no-verify       # Skip pre-commit hooks
```

**Features:**
- Shows modified and untracked files
- Asks for confirmation before proceeding
- Remembers last commit messages per repository
- Suggests conventional commit types (fix, feat, docs, style, refactor, test, chore, revert)
- Automatic retry logic with progress indicator
- Rebase-friendly git pull before push
- Colorized output with emoji

**Dependencies:**
- `gum` - Interactive prompts
- `git` - Version control
- `revolver` - Progress spinner
- `tput` - Terminal control

---

### pull-all

**Description:** Performs `git pull --rebase` on all repositories in a directory in parallel.

**Usage:**
```bash
pull-all ~/path/to/repos
```

**Features:**
- Processes multiple repositories in parallel for faster updates
- Shows progress bar and ETA
- Rebases changes to avoid merge commits

**Parameters:**
- `$1` - Base directory containing subdirectories with git repositories

**Dependencies:**
- `parallel` - GNU Parallel
- `git` - Version control

**Example:**
```bash
pull-all ~/Work       # Update all repos in ~/Work directory
```

---

### gh-clone-all

**Description:** Clones all repositories from a GitHub organization in parallel.

**Usage:**
```bash
gh-clone-all <github_org> <base_directory>
```

**Features:**
- Fetches complete list of repos from GitHub organization
- Clones only if directory doesn't exist (safe to re-run)
- Parallel cloning for speed
- Progress indicator with ETA

**Parameters:**
- `$1` - GitHub organization name
- `$2` - Base directory where repositories will be cloned

**Dependencies:**
- `gh` - GitHub CLI
- `git` - Version control
- `parallel` - GNU Parallel
- `revolver` - Progress spinner
- `tput` - Terminal control

**Example:**
```bash
gh-clone-all coderabbitai ~/Work
gh-clone-all my-org ~/projects
```

---

### sync-coderabbitai

**Description:** Syncs CodeRabbit organization repositories, installs dependencies, and sets up git hooks.

**Usage:**
```bash
sync-coderabbitai
```

**Features:**
- Clones all CodeRabbit repositories
- Updates existing repositories
- Auto-detects and uses appropriate package manager (pnpm, yarn, npm)
- Installs dependencies in all found projects
- Sets up husky git hooks in mono repository

**Behavior:**
1. Clones/updates CodeRabbit repositories to `$HOME/Work/coderabbitai`
2. Finds all `package.json` files up to 2 levels deep
3. Installs dependencies using detected package manager
4. Initializes husky in the mono repository

**Dependencies:**
- `gh-clone-all` - Repository cloning script
- `pull_all` - Repository update script
- `find` - File search utility
- `pnpm`, `yarn`, `npm` - Package managers (at least one required)
- `husky` - Git hooks manager

---

### sync-fluxninja

**Description:** Similar to `sync-coderabbitai` but for FluxNinja organization repositories.

**Usage:**
```bash
sync-fluxninja
```

**Note:** Implementation follows the same pattern as `sync-coderabbitai`.

---

### sync-brews

**Description:** Updates Homebrew packages and manages local brew configuration.

**Usage:**
```bash
sync-brews
```

**Features:**
- Updates Homebrew formula and package cache
- Upgrades installed packages
- Removes unused dependencies
- Supports both system and local Homebrew installations
- Allows custom packages via `~/.brew_local` file

**Configuration:**
Create `~/.brew_local` to add custom Homebrew packages:
```bash
# Example: ~/.brew_local
brew install custom-package-1
brew install custom-package-2
```

**Dependencies:**
- `brew` - Homebrew package manager

---

### spinner

**Description:** Runs a command in background with a progress spinner and optional watch mode.

**Usage:**
```bash
spinner [-s] [-c] [-q] [-w <seconds>] <command> [arguments...]
```

**Options:**
- `-s` - Enable spinner display
- `-c` - Enable colored output
- `-q` - Quiet mode (suppress output)
- `-w <seconds>` - Watch interval for file monitoring

**Features:**
- Displays running spinner while command executes
- Shows command output or summary
- Supports background execution
- Optional watch mode for continuous monitoring

**Dependencies:**
- `revolver` - Progress spinner
- `tput` - Terminal control

**Example:**
```bash
spinner -s "npm install"
spinner -c "docker build ."
```

---

### win-split

**Description:** Splits windows for tmux terminal layout management.

**Note:** Primary purpose is tmux integration. See `.tmux.conf` for integration details.

---

### wttr

**Description:** Display weather information.

**Usage:**
```bash
wttr
wttr London
wttr ~Prague
```

**Features:**
- Show weather for current location or specified city
- Uses wttr.in API
- Locale-aware formatting

---

### explain-prompt

**Description:** Explain git status symbols in the prompt.

**Usage:**
```bash
explain-prompt
```

**Output:**
Displays explanation of git status flags used in the zsh prompt, such as:
- Branch information flags
- Stashed changes
- Untracked files
- And other git status indicators

---

### gh-checks-status

**Description:** Display GitHub Actions checks status for a repository.

**Usage:**
```bash
gh-checks-status
```

**Features:**
- Shows latest workflow run status
- Displays individual check results
- Color-coded output for quick scanning

**Dependencies:**
- `gh` - GitHub CLI
- `jq` - JSON processor (optional)

---

## tools/ - Helper Scripts

These scripts are helper utilities used by other scripts or installation processes.

### install.sh

**Description:** Main installation script for setting up the dotfiles environment.

**Usage:**
```bash
bash tools/install.sh
```

**Interactive Setup Process:**
1. Prompts for Homebrew installation preference (system or local)
2. Installs required tools (gh, chezmoi, zsh, gum)
3. Adds zsh to system shells and sets as default
4. Authenticates with GitHub via SSH
5. Backs up existing git configuration
6. Prompts for name and email (validates input)
7. Initializes chezmoi and applies dotfiles
8. Runs autoupdate script
9. Prompts for reboot confirmation

**Security Features:**
- Input validation for email and name
- Escaping of special characters for gitconfig
- Safe temporary file handling
- Confirmation before reboot

**Dependencies:**
- `curl` or `wget` - Download tools
- `gum` - Interactive prompts
- `gh` - GitHub CLI
- `chezmoi` - Dotfile manager

---

### install_gruvbox.sh

**Description:** Installs the Gruvbox color theme for terminal applications.

**Usage:**
```bash
bash tools/install_gruvbox.sh
```

**Features:**
- Detects OS (macOS or Linux)
- Downloads color configuration from Gogh project
- Applies colors to terminal
- Configurable via `BASE_URL` environment variable

**Environment Variables:**
- `BASE_URL` - Repository URL for color scripts (default: Gogh master)

**Dependencies:**
- `curl` (macOS) or `wget` (Linux) - Download tools
- `bash` - Shell interpreter

---

### dotfiles-edit.sh

**Description:** Opens dotfiles and local overrides in Neovim for editing.

**Usage:**
```bash
bash tools/dotfiles-edit.sh           # Edit global dotfiles
bash tools/dotfiles-edit.sh personal  # Edit personal dotfiles
```

**Global Dotfiles Opened:**
- `.vimrc` - Vim configuration
- `.config/nvim/init.vim` - Neovim configuration
- `.config/nvim/coc-settings.json` - CoC plugin settings
- `.zshrc` - Zsh configuration
- `.gitconfig` - Git configuration
- `.gitignore` - Git ignore rules
- `.zprofile` - Zsh profile
- `.tmux.conf` - Tmux configuration
- `~/sw/bin/autoupdate.zsh` - Autoupdate script
- `~/sw/bin/sync_brews.sh` - Brew sync script

**Personal Dotfiles (with `personal` argument):**
- `.gitconfig_local` - Local git configuration
- `.vimrc_local` - Local vim overrides
- `.vimrc_plugins` - Additional vim plugins
- `.autoupdate_local.zsh` - Custom autoupdate commands
- `.tmux.conf_local` - Local tmux overrides
- `.brew_local` - Custom brew packages

**Dependencies:**
- `nvim` - Neovim editor

---

### error-handling.sh

**Description:** Shared error handling utilities for all shell scripts.

**Usage:**
```bash
source "$(dirname "$0")/error-handling.sh"

# Now available functions:
check_dependencies git gh parallel
success "All dependencies found"
```

**Available Functions:**
- `check_dependency <cmd>` - Check if command exists
- `check_dependencies <cmd1> <cmd2> ...` - Check multiple commands
- `die <message> [exit_code]` - Exit with error message
- `warn <message>` - Display warning
- `success <message>` - Display success message
- `try <command>` - Execute with error checking
- `ensure_dir <path>` - Create directory if not exists
- `require_args <count>` - Validate argument count
- `require_var <name> <value>` - Ensure variable is set
- `safe_mktemp` - Create secure temporary file
- `log <message>` - Log with timestamp
- And more utility functions...

**Features:**
- Consistent color-coded output
- Automatic cleanup on exit
- Standardized error handling

---

### utils.zsh

**Description:** Zsh utility functions and color definitions.

**Features:**
- ANSI color definitions (basic and bright colors)
- `zsh_stats` - Show zsh history statistics
- `br` - Broot integration function
- Silent background command execution
- Miscellaneous helper functions

**Color Variables:**
- `RED`, `GREEN`, `BLUE`, `YELLOW`, `CYAN`, `MAGENTA`, `WHITE`
- `RED_BRIGHT`, `GREEN_BRIGHT`, etc. (bright variants)
- `RESET` - Reset color codes

**Usage in scripts:**
```bash
source tools/utils.zsh
echo -e "${RED}Error message${RESET}"
```

---

### insults.zsh

**Description:** Display witty insult messages when command is not found.

**Features:**
- Random insult generation when typing invalid commands
- Integrates with `thefuck` command-line tool
- Toggleable via `$INSULTS_ENABLED` variable

**Configuration:**
```bash
# In .zshrc_local
INSULTS_ENABLED=true
```

---

### set_colors.zsh

**Description:** Configure terminal and application colors.

**Features:**
- Sets terminal colors via escape codes
- Configures color themes for various tools
- Applies Gruvbox color scheme by default

---

### iterm2_default.py

**Description:** Python script for iTerm2 terminal configuration.

**Note:** Used on macOS with iTerm2 terminal emulator. Requires iTerm2 with Python API support.

---

## Configuration & Customization

### Adding Custom Scripts

1. **For global scripts:** Add to `bin/` directory
2. **For helper scripts:** Add to `tools/` directory
3. **Make executable:** `chmod +x bin/my-script`
4. **Add documentation:** Update this file

### Local Overrides

Many scripts respect local configuration files:
- `~/.zshrc_local` - Local shell configuration
- `~/.vimrc_local` - Local vim settings
- `~/.autoupdate_local.zsh` - Custom autoupdate commands
- `~/.brew_local` - Custom brew packages
- `~/.tmux.conf_local` - Local tmux settings
- `.gitconfig_local` - Local git configuration

### Error Handling

All scripts should use the shared error handling library:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/../tools/error-handling.sh"

check_dependencies git npm
require_args 1 "$@"

# Your script here
```

---

## Dependencies Summary

### Required Tools
- `git` - Version control
- `bash` and/or `zsh` - Shell interpreters
- `chezmoi` - Dotfile management
- `gh` - GitHub CLI
- `gum` - Interactive command-line tool

### Optional Tools
- `brew` - Homebrew package manager
- `revolver` - Progress spinner
- `parallel` - GNU Parallel
- `nvim` - Neovim editor
- `tmux` - Terminal multiplexer
- `npm`, `pnpm`, `yarn` - JavaScript package managers
- `pip3` - Python package manager
- `zinit` - Zsh plugin manager
- `vale` - Prose linter

---

## Troubleshooting

### Script fails with "command not found"

Check the dependencies section for the script and install missing tools:
```bash
# Check what's missing
bash tools/error-handling.sh  # Test error handling
which git npm chezmoi         # Check if tools are installed
```

### Permission denied when running script

Make the script executable:
```bash
chmod +x bin/my-script
```

### Script runs but produces unexpected output

Run with debug mode:
```bash
bash -x bin/my-script
```

---

## See Also

- [README.md](README.md) - Main project documentation
- [PROJECT_REVIEW.md](PROJECT_REVIEW.md) - Detailed project analysis
- [CRITICAL_FIXES.md](CRITICAL_FIXES.md) - Security fixes documentation
