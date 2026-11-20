function ports --description 'list listening TCP ports (optionally filter by port)'
    if test (uname) = Darwin
        lsof -nP -iTCP -sTCP:LISTEN | if set -q argv[1]; grep -E ":$argv[1]\b"; else; cat; end
    else
        ss -ltnp | if set -q argv[1]; grep -E ":$argv[1]\b"; else; cat; end
    end
end
