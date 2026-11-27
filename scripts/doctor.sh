#!/usr/bin/env bash
# What's linked, installed and missing.
. "$(dirname "$0")/lib.sh"

echo "os: $(uname -s) $(uname -m)"
echo "links:"; "$DOTFILES/scripts/link.sh" status
echo "tools:"
export PATH="$(fish -c 'string join : $PATH' 2>/dev/null || echo "$PATH")"   # what your shell sees
for c in fish just git gh glab rg fd bat eza fzf zoxide direnv jq podman k3d kubectl helm k9s \
         nvim lazygit claude codex pi headroom rex ghostty zed; do
  if command -v "$c" >/dev/null 2>&1 || ls -d /Applications/*.app 2>/dev/null | grep -qi "/$c.app$"; then
    printf '  ok       %s\n' "$c"; else printf '  missing  %s\n' "$c"; fi
done
echo "login shell: $(login_shell)"
git config --global user.email >/dev/null || echo "git identity: not set — just git-identity \"Name\" email"
