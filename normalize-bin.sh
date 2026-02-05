#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="bin"

echo "✨ Normalizing bin/ command names..."

git_mv_or_mv() {
  local src="$1"
  local dst="$2"

  [[ "$src" == "$dst" ]] && return 0
  [[ -e "$dst" ]] && {
    echo "⚠️  skip (exists): $dst"
    return 0
  }

  if git ls-files --error-unmatch "$src" >/dev/null 2>&1; then
    git mv "$src" "$dst"
    echo "✔ git mv $src → $dst"
  else
    mv "$src" "$dst"
    echo "✔ mv $src → $dst"
  fi
}

for file in "$BIN_DIR"/*; do
  [[ -f "$file" ]] || continue

  base="$(basename "$file")"

  # strip extensions
  name="${base%.sh}"
  name="${name%.zsh}"

  # normalize underscores → hyphens
  name="${name//_/-}"

  # skip if unchanged
  [[ "$base" == "$name" ]] && continue

  git_mv_or_mv "$file" "$BIN_DIR/$name"
done

echo
echo "✅ bin/ normalization complete."
echo "👉 Verify with: ls bin/"
