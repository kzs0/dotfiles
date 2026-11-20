set -gx LANG en_US.UTF-8
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache

# Editor: zed when available, otherwise vim
if type -q zed
    set -gx EDITOR "zed --wait"
else if type -q zeditor
    set -gx EDITOR "zeditor --wait"
else
    set -gx EDITOR vim
end
set -gx VISUAL $EDITOR
set -gx PAGER less
set -gx LESS -FRX

# npm globals in user space (no sudo) — used for the pi agent
set -gx NPM_CONFIG_PREFIX $HOME/.local/share/npm

# bat / man
set -gx BAT_THEME ansi
type -q bat; and set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# fzf defaults
type -q fd; and set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

# Podman as the docker API for k3d & friends. `just setup podman` stores the socket
# path in the universal var DOTFILES_PODMAN_SOCK (machine-local, not in git).
if set -q DOTFILES_PODMAN_SOCK; and test -S $DOTFILES_PODMAN_SOCK
    set -gx DOCKER_HOST unix://$DOTFILES_PODMAN_SOCK
end
