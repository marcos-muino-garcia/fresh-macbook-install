#!/usr/bin/env bash
# Install Homebrew (if missing) and apply the Brewfile.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew update
brew bundle --file "$REPO_ROOT/Brewfile"

# Show what would be removed by cleanup; only actually remove if BREW_CLEANUP=1.
# Re-run as `BREW_CLEANUP=1 ./install.sh` to prune everything not in the Brewfile.
if [[ "${BREW_CLEANUP:-0}" == "1" ]]; then
  brew bundle cleanup --file "$REPO_ROOT/Brewfile" --force
else
  brew bundle cleanup --file "$REPO_ROOT/Brewfile" || true
fi

# fzf shell integration files (key-bindings + completion).
if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish --no-update-rc
fi

# Symlink openjdk@21 so /usr/libexec/java_home and other JVM tools see it.
if brew list --formula | grep -q '^openjdk@21$'; then
  if [[ ! -L /Library/Java/JavaVirtualMachines/openjdk-21.jdk ]]; then
    sudo ln -sfn \
      "$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk" \
      /Library/Java/JavaVirtualMachines/openjdk-21.jdk \
      || echo "WARN: could not symlink openjdk-21 system-wide (skip if no sudo)."
  fi
fi
