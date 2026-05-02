#!/usr/bin/env bash
# Configure Git identity, sensible defaults, and an SSH key for GitHub.
set -euo pipefail

# ----- Identity -----------------------------------------------------------
if [[ -z "$(git config --global user.name 2>/dev/null || true)" ]]; then
  read -rp "Git user.name: " git_name
  git config --global user.name "$git_name"
fi
if [[ -z "$(git config --global user.email 2>/dev/null || true)" ]]; then
  read -rp "Git user.email: " git_email
  git config --global user.email "$git_email"
fi

# ----- Sensible defaults --------------------------------------------------
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global rerere.enabled true
git config --global merge.conflictstyle zdiff3
git config --global diff.algorithm histogram
git config --global column.ui auto
git config --global branch.sort -committerdate

# Delta as pager.
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global delta.side-by-side false

# Pull in the bundled delta themes (installed via stow at ~/.config/delta/themes.gitconfig).
if [[ -f "$HOME/.config/delta/themes.gitconfig" ]]; then
  git config --global include.path "$HOME/.config/delta/themes.gitconfig"
fi

# ----- SSH key (optional) -------------------------------------------------
# Some users manage their GitHub SSH keys elsewhere (1Password, a yubikey,
# a corporate identity flow, …) and don't want a fresh ed25519 key
# generated under ~/.ssh. Make the whole flow opt-in when no key exists.
EMAIL="$(git config --global user.email)"
KEY="$HOME/.ssh/id_ed25519"
NEW_KEY=0
SETUP_SSH=1

if [[ ! -f "$KEY" ]]; then
  if [[ -t 0 ]]; then
    read -rp "Generate an ed25519 SSH key for GitHub? [Y/n] " ans
    case "${ans:-y}" in
      [Yy]*) ;;
      *) SETUP_SSH=0; echo "Skipping SSH key generation." ;;
    esac
  fi
fi

if [[ "$SETUP_SSH" == "1" ]]; then
  if [[ ! -f "$KEY" ]]; then
    echo "Generating ed25519 SSH key for $EMAIL..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N ""
    NEW_KEY=1
  fi

  # Ensure ~/.ssh/config has a GitHub block that uses the macOS keychain.
  SSH_CFG="$HOME/.ssh/config"
  touch "$SSH_CFG"
  chmod 600 "$SSH_CFG"
  if ! grep -q "Host github.com" "$SSH_CFG" 2>/dev/null; then
    cat <<'EOF' >> "$SSH_CFG"

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
  fi

  # Add the key to the macOS keychain-backed ssh-agent (idempotent).
  ssh-add --apple-use-keychain "$KEY" 2>/dev/null \
    || ssh-add -K "$KEY" 2>/dev/null \
    || ssh-add "$KEY" 2>/dev/null \
    || true

  # ----- Tell the user how to register it on GitHub ---------------------
  HOST_LABEL="$(scutil --get ComputerName 2>/dev/null || hostname)"

  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy < "${KEY}.pub"
    CLIP_NOTE="(public key has been copied to your clipboard)"
  else
    CLIP_NOTE=""
  fi

  cat <<EOF

================================================================================
SSH key ready: ${KEY}.pub  ${CLIP_NOTE}

Add it to GitHub — pick ONE of these flows:

  A) Web UI
     1. Open https://github.com/settings/ssh/new
     2. Title: ${HOST_LABEL}
     3. Key type: "Authentication Key" (paste from clipboard)
     4. Click "Add SSH key"
     5. (Optional) Repeat with key type "Signing Key" if you want SSH commit
        signing, then run:
          git config --global gpg.format ssh
          git config --global user.signingkey ~/.ssh/id_ed25519.pub
          git config --global commit.gpgsign true

  B) GitHub CLI (after \`gh auth login\`)
       gh ssh-key add "${KEY}.pub" --title "${HOST_LABEL}" --type authentication
       gh ssh-key add "${KEY}.pub" --title "${HOST_LABEL} (signing)" --type signing

Verify:
  ssh -T git@github.com
  # Expect: "Hi <username>! You've successfully authenticated..."
================================================================================
EOF

  # Pause so the user can register the key on GitHub before the next script
  # (40-shell.sh clones Prezto and would otherwise scroll these instructions
  # off-screen). Only block when we actually generated a new key in this run
  # AND stdin is a TTY — otherwise just continue (e.g. CI, piped install).
  if [[ "$NEW_KEY" == "1" && -t 0 ]]; then
    read -rp "Press Enter once the key is added to GitHub (or Ctrl+C to abort)... " _ || true
  fi
fi
