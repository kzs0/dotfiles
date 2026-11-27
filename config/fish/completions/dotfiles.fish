# Tab-complete just recipes for `dotfiles` (and the shortcut that wraps it).
function __dotfiles_recipes
    set -l dir (set -q DOTFILES; and echo $DOTFILES; or echo $HOME/dotfiles)
    just --justfile $dir/justfile --list --list-heading '' --list-prefix '' 2>/dev/null |
        string replace -r '^(\S+)[^#]*(?:#\s*(.*))?$' '$1'\t'$2'
end
complete -c dotfiles -f -n __fish_use_subcommand -a '(__dotfiles_recipes)'
