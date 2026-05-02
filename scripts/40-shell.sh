#!/usr/bin/env bash
# Install/update Prezto. Pinned to a specific ref for reproducibility.
set -euo pipefail

# Pin Prezto. Bump by running:
#   git -C ~/.zprezto rev-parse HEAD
# and pasting the new SHA here.
PREZTO_REF="${PREZTO_REF:-master}"

PREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"

if [[ ! -d "$PREZTO_DIR" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$PREZTO_DIR"
fi

git -C "$PREZTO_DIR" fetch --all --tags --prune

if git -C "$PREZTO_DIR" show-ref --verify --quiet "refs/heads/${PREZTO_REF}"; then
  git -C "$PREZTO_DIR" checkout "$PREZTO_REF"
  git -C "$PREZTO_DIR" pull --ff-only origin "$PREZTO_REF"
else
  git -C "$PREZTO_DIR" checkout --detach "$PREZTO_REF"
fi

git -C "$PREZTO_DIR" submodule update --init --recursive

if [[ "$PREZTO_REF" == "master" ]]; then
  cat <<'EOF'

NOTE: PREZTO_REF is currently "master" (a moving target). For full reproducibility
      run `git -C ~/.zprezto rev-parse HEAD` and paste the SHA into
      scripts/40-shell.sh as PREZTO_REF.
EOF
fi
