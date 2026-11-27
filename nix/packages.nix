# Linux package set — keep in sync with ../Brewfile (macOS).
# `cloud` is the list picked in `just configure` (DOTFILES_CLOUD), e.g. [ "gcloud" "aws" ].
{ pkgs, gui ? false, cloud ? [ ] }:
with pkgs;
[
  # shell
  fish
  just

  # git forges
  git
  delta
  gh
  glab

  # everyday utilities
  bat
  btop
  coreutils
  curl
  direnv
  eza
  fd
  fzf
  gnused
  jq
  yq-go
  ripgrep
  tealdeer
  tree
  watch
  wget
  zoxide
  unzip
  lsof
  nodejs # for the pi coding agent (npm)
  neovim
  lazygit
  tree-sitter
  gcc # tree-sitter parser builds
  uv # python tools (headroom)
  mise # language versions picked in `just configure`

  # agents
  codex

  # containers & kubernetes
  # (podman comes from the OS: `virtualisation.podman` on NixOS, apt on Ubuntu —
  #  it needs setuid helpers and systemd units that a user profile can't provide)
  k3d
  kubectl
  kubectx
  kubernetes-helm
  k9s

  # fonts
  nerd-fonts.jetbrains-mono
]
++ lib.optionals gui [
  ghostty
  zed-editor
]
++ lib.optional (builtins.elem "gcloud" cloud) google-cloud-sdk
++ lib.optional (builtins.elem "aws" cloud) awscli2
++ lib.optional (builtins.elem "azure" cloud) azure-cli
