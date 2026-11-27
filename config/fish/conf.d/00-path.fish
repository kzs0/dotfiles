# PATH + package manager setup. Runs for every fish (interactive or not).

# Homebrew (macOS / Linuxbrew)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end

# Nix (single-user or daemon install; NixOS already sets this up)
for nixprof in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish $HOME/.nix-profile/etc/profile.d/nix.fish
    if test -e $nixprof
        source $nixprof # these scripts guard against double-sourcing themselves
        break
    end
end
test -d $HOME/.nix-profile/bin; and fish_add_path -g $HOME/.nix-profile/bin

# Rex CLI ships inside the app bundle
set -l rexbin "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
test -d $rexbin; and fish_add_path -ga $rexbin

# mise (language versions): full activation in interactive shells, shims elsewhere
if type -q mise
    if status is-interactive
        mise activate fish | source
    else
        fish_add_path -g $HOME/.local/share/mise/shims
    end
end

# User bins (claude installs to ~/.local/bin; npm globals go to ~/.local/share/npm/bin)
fish_add_path -g $HOME/.local/bin $HOME/.local/share/npm/bin $HOME/go/bin $HOME/.cargo/bin
