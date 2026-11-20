function __mac_backspace --description 'backspace that deletes the selection when there is one'
    if commandline -B >/dev/null 2>&1
        commandline -f kill-selection end-selection
    else
        commandline -f backward-delete-char
    end
end
