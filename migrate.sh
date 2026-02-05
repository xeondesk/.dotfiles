#!/usr/bin/env bash
set -euo pipefail

echo "🚚 Migrating dotfiles structure..."

# --- helpers ---------------------------------------------------------------

move_if_exists() {
  local src="$1"
  local dst="$2"

  if [[ -e "$src" && ! -e "$dst" ]]; then
    mkdir -p "$(dirname "$dst")"
    git mv "$src" "$dst"
    echo "✔ moved $src → $dst"
  fi
}

mkdir -p \
  home \
  config \
  config/zsh/completions \
  bin \
  tools \
  assets/{images,audio,themes,wallpapers} \
  vim/after/autoload/coc

# --- home (~) ---------------------------------------------------------------

move_if_exists dot_aliases              home/.aliases
move_if_exists dot_gitconfig            home/.gitconfig
move_if_exists dot_golangci.yml         home/.golangci.yml
move_if_exists dot_prettierrc           home/.prettierrc
move_if_exists dot_tmux.conf            home/.tmux.conf
move_if_exists dot_tmux.conf.settings   home/.tmux.conf.settings
move_if_exists dot_urlview              home/.urlview
move_if_exists dot_vimrc                home/.vimrc
move_if_exists dot_zprofile             home/.zprofile
move_if_exists dot_zshrc                home/.zshrc

# --- ~/.config --------------------------------------------------------------

move_if_exists dot_config/broot         config/broot
move_if_exists dot_config/fsh           config/fsh
move_if_exists dot_config/ghostty       config/ghostty
move_if_exists dot_config/nvim          config/nvim
move_if_exists dot_config/pip           config/pip
move_if_exists dot_config/smug          config/smug

# completions
if [[ -d dot_completions ]]; then
  git mv dot_completions/* config/zsh/completions/ || true
  rmdir dot_completions || true
  echo "✔ moved zsh completions"
fi

# --- vim extras -------------------------------------------------------------

move_if_exists dot_vim/after/autoload/coc/ui.vim \
               vim/after/autoload/coc/ui.vim

# --- bin (executables) ------------------------------------------------------

if [[ -d sw/bin ]]; then
  for f in sw/bin/*; do
    name="$(basename "$f" | sed 's/^executable_//')"
    move_if_exists "$f" "bin/$name"
  done
  rmdir sw/bin || true
fi

# --- tools (non-PATH scripts) -----------------------------------------------

if [[ -d sw/assets ]]; then
  for f in sw/assets/executable_*; do
    [[ -e "$f" ]] || continue
    name="$(basename "$f" | sed 's/^executable_//')"
    move_if_exists "$f" "tools/$name"
  done
fi

# --- assets -----------------------------------------------------------------

if [[ -d sw/assets ]]; then
  for f in sw/assets/*.{png,jpg,jpeg,heic}; do
    [[ -e "$f" ]] && move_if_exists "$f" "assets/images/$(basename "$f")"
  done

  for f in sw/assets/*.{ogg,wav,mp3}; do
    [[ -e "$f" ]] && move_if_exists "$f" "assets/audio/$(basename "$f")"
  done

  for f in sw/assets/*.json sw/assets/*.config; do
    [[ -e "$f" ]] && move_if_exists "$f" "assets/themes/$(basename "$f")"
  done
fi

# --- notes ------------------------------------------------------------------

move_if_exists notes/dot_vale.ini notes/vale.ini

# --- cleanup ----------------------------------------------------------------

rmdir dot_config 2>/dev/null || true
rmdir dot_vim    2>/dev/null || true
rmdir sw/assets  2>/dev/null || true
rmdir sw         2>/dev/null || true

echo
echo "✅ Migration complete."
echo "Next steps:"
echo "  1. Review git status"
echo "  2. Update README"
echo "  3. Add stow / chezmoi"
