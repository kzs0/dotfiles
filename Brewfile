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
brew "mise"         # language versions picked in `just configure` (python, go, node, rust)

# --- containers & kubernetes -------------------------------------------------
brew "podman"
brew "k3d"
brew "kubernetes-cli"
brew "kubectx"
brew "helm"
brew "k9s"

# --- cloud CLIs: only the ones picked in `just configure` (DOTFILES_CLOUD) --------
cloud = ENV.fetch("DOTFILES_CLOUD", "").split
cask "gcloud-cli" if cloud.include?("gcloud")
brew "awscli"     if cloud.include?("aws")
brew "azure-cli"  if cloud.include?("azure")

# --- macOS apps --------------------------------------------------------------
if OS.mac?
  cask "ghostty"
  cask "zed"
  cask "codex"
  cask "font-jetbrains-mono-nerd-font"
  # Atkinson Hyperlegible (Braille Institute): the original, Next, and Mono
  cask "font-atkinson-hyperlegible"
  cask "font-atkinson-hyperlegible-next"
  cask "font-atkinson-hyperlegible-mono"
end
