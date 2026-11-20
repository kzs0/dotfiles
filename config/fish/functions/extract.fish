function extract --description 'extract any common archive'
    for f in $argv
        if not test -f $f
            echo "extract: '$f' is not a file" >&2; return 1
        end
        switch $f
            case '*.tar.gz' '*.tgz';   tar xzf $f
            case '*.tar.bz2' '*.tbz2'; tar xjf $f
            case '*.tar.xz' '*.txz';   tar xJf $f
            case '*.tar.zst';          tar --zstd -xf $f
            case '*.tar';              tar xf $f
            case '*.gz';               gunzip $f
            case '*.bz2';              bunzip2 $f
            case '*.xz';               unxz $f
            case '*.zip';              unzip $f
            case '*.7z';               7z x $f
            case '*'; echo "extract: don't know how to extract '$f'" >&2; return 1
        end
    end
end
