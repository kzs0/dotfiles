# ~/.config/fish/config.fish — managed by ~/dotfiles (edit there).
# conf.d/* runs first (PATH, env, fisher plugins).

if status is-interactive
    set -g fish_greeting

    # --- prompt: tide ------------------------------------------------------
    # Installed by fisher (ilancosman/tide). `tide configure` to restyle, then
    # `just prompt-save` to make it the default on every machine.

    # --- tool integrations -------------------------------------------------
    type -q zoxide; and zoxide init fish | source
    type -q direnv; and direnv hook fish | source
    type -q rex; and rex completion fish | source

    # --- aliases & abbreviations --------------------------------------------
    source $__fish_config_dir/aliases.fish
end

# Machine-specific overrides and secrets (untracked)
test -f $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish
