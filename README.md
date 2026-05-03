# Fresh MacBook Install

My personal "fresh MacBook" setup. Installs Homebrew packages, links my dotfiles
into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/), applies sane
macOS defaults, configures git, and generates an SSH key for GitHub.

Everything is idempotent — running `./install.sh` again is safe and only does
the work that's still needed.

## Prerequisites

A brand-new Mac doesn't ship `git` directly — it ships a stub that, the first
time you invoke `git`, triggers the Xcode Command Line Tools GUI installer.
You need to clear that one hurdle before you can clone this repo:

```bash
xcode-select --install
```

Click through the GUI prompt and wait for it to finish (a few minutes). After
that, `git` is on your `PATH` and you can proceed. Homebrew (installed in step 1
of `install.sh`) will later put a newer `git` from this repo's Brewfile in
front of Apple's stub, so this CLT version is only used for the initial clone.

> If you'd rather skip this manual step, see [Bootstrap one-liner](#bootstrap-one-liner)
> below.

## Quick start

```bash
git clone https://github.com/marcos-muino-garcia/fresh-macbook-install.git ~/workspace/fresh-macbook-install
cd ~/workspace/fresh-macbook-install
./install.sh
```

### Bootstrap one-liner

To install CLT, clone the repo, and kick off `install.sh` in one shot:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/marcos-muino-garcia/fresh-macbook-install/main/bootstrap.sh)"
```

See [`bootstrap.sh`](./bootstrap.sh).

The first run will:

1. Install Homebrew (if missing) and apply [`Brewfile`](./Brewfile).
2. Symlink everything under [`dotfiles/`](./dotfiles/) into `$HOME` (any existing
   non-symlink files are backed up to `*.bak.<timestamp>`).
3. Apply macOS defaults (screenshot folder, key-repeat speed, Finder/Dock tweaks…).
4. Prompt for `git user.name` / `user.email`, set sensible git defaults, and
   generate an `ed25519` SSH key (with macOS Keychain integration).
5. Install/update [Prezto](https://github.com/sorin-ionescu/prezto) at the
   pinned `PREZTO_REF`.

After it finishes, it prints instructions for adding your new SSH key to GitHub.

## Layout

```
.
├── install.sh              # orchestrator — runs scripts/*.sh in order
├── Brewfile                # one source of truth for installed packages
├── scripts/
│   ├── 00-brew.sh          # Homebrew + Brewfile + fzf integration
│   ├── 10-dotfiles.sh      # stow each package in dotfiles/ into $HOME
│   ├── 20-macos.sh         # `defaults write ...`
│   ├── 30-git.sh           # git config + SSH key + GitHub onboarding
│   └── 40-shell.sh         # Prezto install/update at a pinned ref
├── dotfiles/               # one subdir per "stow package"
│   ├── zsh/                # ~/.zshrc, ~/.zpreztorc
│   ├── vim/                # ~/.vimrc
│   ├── ghostty/            # ~/.config/ghostty/config
│   ├── karabiner/          # ~/.config/karabiner/karabiner.json
│   ├── lazygit/            # ~/.config/lazygit/config.yml
│   ├── delta/              # ~/.config/delta/themes.gitconfig
│   └── mise/               # ~/.config/mise/config.toml
├── templates/
│   └── .zshrc.local.example  # copied to ~/.zshrc.local on first run
└── .github/workflows/shellcheck.yml
```

## Daily workflow

Because dotfiles are symlinked (not copied), editing `~/.zshrc` _is_ editing
`dotfiles/zsh/.zshrc`. Commit and push from the repo as you go.

```bash
cd ~/workspace/fresh-macbook-install
git diff
git commit -am "tweak zshrc"
```

To re-link after adding new files to a stow package:

```bash
bash scripts/10-dotfiles.sh
```

To prune Homebrew packages no longer in the Brewfile:

```bash
BREW_CLEANUP=1 ./install.sh
```

## Machine-specific config

Anything that depends on a specific machine's filesystem layout (work paths,
project aliases, secrets) goes in `~/.zshrc.local`, which is sourced from
`~/.zshrc` but **not** tracked in this repo. A starter copy is installed from
[`templates/.zshrc.local.example`](./templates/.zshrc.local.example).

## Pinning Prezto

[`scripts/40-shell.sh`](./scripts/40-shell.sh) reads `PREZTO_REF`. After the
first install, pin a known-good commit:

```bash
git -C ~/.zprezto rev-parse HEAD
# Paste the SHA into PREZTO_REF in scripts/40-shell.sh and commit.
```

## CI

[`.github/workflows/shellcheck.yml`](./.github/workflows/shellcheck.yml) runs
[ShellCheck](https://www.shellcheck.net/) on every push and PR.
