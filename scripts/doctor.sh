#!/usr/bin/env bash
# What's linked, installed and missing.
. "$(dirname "$0")/lib.sh"
load_state

echo "os: $(uname -s) $(uname -m)"
echo "links:"; "$DOTFILES/scripts/link.sh" status
echo "tools:"
export PATH="$(fish -c 'string join : $PATH' 2>/dev/null || echo "$PATH")"   # what your shell sees
for c in fish just git gh glab rg fd bat eza fzf zoxide direnv jq podman k3d kubectl helm k9s \
         nvim lazygit mise claude codex pi headroom rex ghostty zed \
         $(for c in $DOTFILES_CLOUD; do case $c in azure) echo az ;; *) echo "$c" ;; esac; done); do
  if command -v "$c" >/dev/null 2>&1 || ls -d /Applications/*.app 2>/dev/null | grep -qi "/$c.app$"; then
    printf '  ok       %s\n' "$c"; else printf '  missing  %s\n' "$c"; fi
done
echo "login shell: $(login_shell)"
if [ -f "$STATE" ]; then
  echo "choices ($STATE):"
  printf '  components  %s\n  languages   %s\n  cloud CLIs  %s\n  command     %s\n' \
    "${DOTFILES_COMPONENTS:-}" "${DOTFILES_LANGS:-none}" "${DOTFILES_CLOUD:-none}" "${DOTFILES_SHORTCUT:-dotfiles}"
  command -v mise >/dev/null && [ -n "$DOTFILES_LANGS" ] && { echo "languages:"; mise ls --global --current 2>/dev/null | sed 's/^/  /'; }
else
  echo "choices: none saved yet — just configure"
fi
git config --global user.email >/dev/null || echo "git identity: not set — just git-identity \"Name\" email"
