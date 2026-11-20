function fish_user_key_bindings --description 'Mac-style navigation (see config/ghostty/config, config/rex/init.lua)'
    # option+←/→ arrive as alt-b / alt-f (preset: backward-word / forward-word)
    # cmd+←/→ arrive as home / end (preset: beginning-of-line / end-of-line)
    # cmd+⌫ arrives as ctrl-u (preset: backward-kill-line)

    # moving without shift ends any selection
    bind left '__mac_move left backward-char'
    bind right '__mac_move right forward-char'
    bind home end-selection beginning-of-line
    bind end end-selection end-of-line
    bind alt-b end-selection backward-word
    bind alt-f end-selection forward-word

    # shift = select
    bind shift-left '__mac_select backward-char'
    bind shift-right '__mac_select forward-char'
    bind alt-shift-left '__mac_select backward-word'
    bind alt-shift-right '__mac_select forward-word'
    bind shift-home '__mac_select beginning-of-line'
    bind shift-end '__mac_select end-of-line'

    bind backspace __mac_backspace
    bind ctrl-h __mac_backspace
end
