#!/usr/bin/env bash
# Symlink dotfiles into $HOME using GNU Stow.
#
# Each subdir of dotfiles/ is a "package" whose tree mirrors $HOME, e.g.
#   dotfiles/zsh/.zshrc                 -> ~/.zshrc
#   dotfiles/ghostty/.config/ghostty/   -> ~/.config/ghostty/
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOTFILES_DIR="$REPO_ROOT/dotfiles"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

PACKAGES=(zsh vim ghostty karabiner lazygit delta)

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: stow not found. Run scripts/00-brew.sh first." >&2
  exit 1
fi

# Back up any existing real (non-symlink) files that would conflict with stow.
for pkg in "${PACKAGES[@]}"; do
  pkg_root="$DOTFILES_DIR/$pkg"
  [[ -d "$pkg_root" ]] || continue
  while IFS= read -r src; do
    rel="${src#$pkg_root/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup="${target}.bak.${TIMESTAMP}"
      mkdir -p "$(dirname "$backup")"
      echo "Backing up $target -> $backup"
      mv "$target" "$backup"
    fi
  done < <(/usr/bin/find "$pkg_root" -type f)
done

mkdir -p "$HOME/.config"

stow --dir="$DOTFILES_DIR" --target="$HOME" --restow --verbose=1 "${PACKAGES[@]}"

# Drop a local override file if it doesn't exist yet.
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$REPO_ROOT/templates/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "Created ~/.zshrc.local — edit it for machine-specific settings."
fi
