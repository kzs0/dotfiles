function killport --description 'kill whatever is listening on a TCP port'
    set -l pids (lsof -t -nP -iTCP:$argv[1] -sTCP:LISTEN 2>/dev/null)
    if test -z "$pids"
        echo "nothing listening on $argv[1]"; return 1
    end
    kill $pids; and echo "killed $pids"
end
