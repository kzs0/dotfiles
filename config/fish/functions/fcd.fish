function fcd --description 'fuzzy cd into a subdirectory'
    set -l dir (fd --type d --hidden --exclude .git . $argv[1] | fzf); and cd $dir
end
