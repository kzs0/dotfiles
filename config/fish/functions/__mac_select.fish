function __mac_select --description 'extend (or start) a selection, then move: __mac_select <input-function>'
    commandline -B >/dev/null 2>&1; or commandline -f begin-selection
    commandline -f $argv
end
