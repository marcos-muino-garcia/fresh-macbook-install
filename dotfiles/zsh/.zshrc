source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vim"
export VISUAL="vim"
export PATH="$HOME/.local/bin:$PATH"

# Java (only if installed via brew).
if [[ -d /opt/homebrew/opt/openjdk@21/bin ]]; then
  export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
fi

# -----------------------------------------------------------------------------
# Tool integrations
# -----------------------------------------------------------------------------
# fzf
export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]   && source /opt/homebrew/opt/fzf/shell/completion.zsh

# zoxide (z / zi commands)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# mise — polyglot version manager (Node, Python, Java, Ruby, ...)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# Listing
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza -T --icons --git-ignore"
alias bcat="bat --paging=never --plain"
alias top="btop"

# Git
alias lg="lazygit"
alias gcom="gco main"
alias gclb='git branch --merged | egrep -v "(^\*|master|main)" | xargs git branch -d'
alias ag="alias | grep git | grep"

# Navigation
alias ..="cd .."
alias ...="cd ../.."

# Editor
alias vsc="code ."

# -----------------------------------------------------------------------------
# Machine-specific overrides (not tracked in git)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
