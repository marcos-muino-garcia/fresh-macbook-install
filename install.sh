#!/usr/bin/env bash
# Top-level orchestrator. Runs the individual setup scripts in order.
#
# Each step is idempotent and safe to re-run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT

SCRIPTS=(
  "00-brew.sh"
  "10-dotfiles.sh"
  "20-macos.sh"
  "30-git.sh"
  "40-shell.sh"
)

for script in "${SCRIPTS[@]}"; do
  printf '\n\033[1;34m==> Running %s\033[0m\n' "$script"
  bash "$REPO_ROOT/scripts/$script"
done

cat <<'EOF'

================================================================================
All done. Open a new terminal session for shell changes to take effect.

Useful next steps:
  - mise use -g node@lts python@3 java@21
  - gh auth login
  - Open Karabiner-Elements once to grant accessibility permissions.
================================================================================
EOF
