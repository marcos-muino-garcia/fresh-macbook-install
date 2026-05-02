#!/usr/bin/env bash
# One-shot bootstrap for a brand-new Mac.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/<you>/<repo>/main/bootstrap.sh)"
#
# Steps:
#   1. Install Xcode Command Line Tools (provides git + cc).
#   2. Clone this repo into ~/workspace/<repo>.
#   3. Run ./install.sh.
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/marcos-muino-garcia/fresh-macbook-install.git}"
TARGET_DIR="${TARGET_DIR:-$HOME/workspace/fresh-macbook-install}"

# 1) Xcode Command Line Tools -------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools (a GUI window will appear)..."
  xcode-select --install || true
  # Wait for the user to finish the GUI installer.
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  echo "==> Xcode Command Line Tools installed."
fi

# 2) Clone --------------------------------------------------------------------
mkdir -p "$(dirname "$TARGET_DIR")"
if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "==> Repo already cloned at $TARGET_DIR — pulling latest."
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "==> Cloning $REPO_URL into $TARGET_DIR..."
  git clone "$REPO_URL" "$TARGET_DIR"
fi

# 3) Run installer ------------------------------------------------------------
cd "$TARGET_DIR"
exec bash ./install.sh
