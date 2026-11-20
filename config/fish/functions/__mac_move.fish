function __mac_move --description 'move without shift: collapse a selection to its edge (left|right), else run the given input function'
    set -l side $argv[1]
    if set -l b (commandline -B 2>/dev/null); and set -l e (commandline -E 2>/dev/null)
        commandline -f end-selection
        if test $side = left
            commandline -C $b
        else
            commandline -C $e
        end
    else
        commandline -f $argv[2..]
    end
end
