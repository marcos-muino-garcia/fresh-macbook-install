#!/usr/bin/env bash
# Install vim plugins as native vim 8+ packages under ~/.vim/pack/.
#
# Each plugin is a git clone into ~/.vim/pack/<group>/start/<name>, which
# vim auto-loads at startup. Re-running this script is idempotent: existing
# plugins are `git pull`-ed, missing ones are cloned.
set -euo pipefail

PACK_DIR="$HOME/.vim/pack"

# Format: "group name git-url"
PLUGINS=(
  "themes catppuccin https://github.com/catppuccin/vim.git"
)

for entry in "${PLUGINS[@]}"; do
  read -r group name url <<<"$entry"
  target="$PACK_DIR/$group/start/$name"
  if [[ -d "$target/.git" ]]; then
    echo "Updating vim plugin: $name"
    git -C "$target" pull --ff-only --quiet || echo "  (skipped: $name has local changes)"
  else
    echo "Installing vim plugin: $name"
    mkdir -p "$(dirname "$target")"
    git clone --depth=1 --quiet "$url" "$target"
  fi
done
