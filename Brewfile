# Core: shell, tooling, and stable everyday utilities.
# `just brew` installs this file. Add things here, not via ad-hoc `brew install`.

# --- shell -------------------------------------------------------------------
brew "fish"
brew "just"

# --- git forges --------------------------------------------------------------
brew "git"
brew "git-delta"
brew "gh"
brew "glab"

# --- everyday utilities ------------------------------------------------------
brew "bat"          # cat with syntax highlighting
brew "btop"         # process monitor
brew "coreutils"
brew "curl"
brew "direnv"       # per-directory env (.envrc)
brew "eza"          # ls replacement
brew "fd"           # find replacement
brew "fzf"
brew "gnu-sed"
brew "jq"
brew "yq"
brew "ripgrep"
brew "tealdeer"     # tldr pages
brew "tree"
brew "watch"
brew "wget"
brew "zoxide"       # smarter cd
brew "node"         # needed for the pi coding agent (npm)
brew "neovim"
brew "lazygit"      # LazyVim git UI (<leader>gg)
brew "tree-sitter-cli" # LazyVim parser builds
brew "uv"           # python tools (headroom)

# --- containers & kubernetes -------------------------------------------------
brew "podman"
brew "k3d"
brew "kubernetes-cli"
brew "kubectx"
brew "helm"
brew "k9s"

# --- macOS apps --------------------------------------------------------------
if OS.mac?
  cask "ghostty"
  cask "zed"
  cask "codex"
  cask "font-jetbrains-mono-nerd-font"
end
