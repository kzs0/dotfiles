function bak --description 'copy a file to file.bak-<timestamp>'
    for f in $argv
        cp -a $f $f.bak-(date +%Y%m%d-%H%M%S)
    end
end
