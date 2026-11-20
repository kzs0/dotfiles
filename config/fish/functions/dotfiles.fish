function dotfiles --description 'run a just recipe in ~/dotfiles (no args: cd there)'
    set -l dir (set -q DOTFILES; and echo $DOTFILES; or echo $HOME/dotfiles)
    if set -q argv[1]
        just --justfile $dir/justfile --working-directory $dir $argv
    else
        cd $dir
    end
end
