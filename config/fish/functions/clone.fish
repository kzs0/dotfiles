function clone --description 'clone a repo into ~/src/<host>/<owner>/<repo> and cd into it'
    # accepts: owner/repo (github), full https/ssh URLs for github or gitlab
    set -l url $argv[1]
    if string match -qr '^[\w.-]+/[\w.-]+$' -- $url
        set url "https://github.com/$url"
    end
    set -l path (string replace -r '^(https?://|git@)' '' -- $url | string replace ':' '/' | string replace -r '\.git$' '')
    set -l dest $HOME/src/$path
    if not test -d $dest
        git clone $url $dest; or return
    end
    cd $dest
end
