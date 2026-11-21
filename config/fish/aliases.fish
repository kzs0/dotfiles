# Abbreviations expand inline (so history shows the real command); aliases for
# drop-in replacements.

# --- navigation / files ----------------------------------------------------
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
if type -q eza
    alias ls 'eza --group-directories-first'
    alias ll 'eza -l --git --group-directories-first'
    alias la 'eza -la --git --group-directories-first'
    alias lt 'eza --tree --level=2 --git-ignore'
else
    alias ll 'ls -lh'
    alias la 'ls -lah'
end
type -q bat; and alias cat 'bat --paging=never'
alias cp 'cp -i'
alias mv 'mv -i'
alias df 'df -h'
alias du 'du -h'
abbr -a md 'mkdir -p'

# --- editor ----------------------------------------------------------------
if type -q nvim
    alias vim nvim
    alias vi nvim
end

# --- git -------------------------------------------------------------------
abbr -a g git
abbr -a gs 'git status -sb'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gca 'git commit --amend'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'
abbr -a gswc 'git switch -c'
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a gl 'git log --oneline --graph --decorate -20'
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a gpl 'git pull --rebase'
abbr -a gf 'git fetch --all --prune'
abbr -a grb 'git rebase'
abbr -a gst 'git stash'
abbr -a gstp 'git stash pop'

# --- forges ----------------------------------------------------------------
abbr -a ghpr 'gh pr create --fill'
abbr -a ghprv 'gh pr view --web'
abbr -a glmr 'glab mr create --fill'
abbr -a glmrv 'glab mr view --web'

# --- containers / kubernetes -------------------------------------------------
type -q docker; or alias docker podman
abbr -a k kubectl
abbr -a kgp 'kubectl get pods'
abbr -a kga 'kubectl get all'
abbr -a kd 'kubectl describe'
abbr -a kl 'kubectl logs -f'
abbr -a kx kubectx
abbr -a kn kubens

# --- misc ------------------------------------------------------------------
abbr -a j just
abbr -a c claude
abbr -a reload 'exec fish'
abbr -a path 'printf "%s\n" $PATH'
abbr -a myip 'curl -s https://ifconfig.me; echo'

# --- macOS -----------------------------------------------------------------
# keep the Mac awake (display, idle, disk, system) until ctrl-c
type -q caffeinate; and abbr -a caf 'caffeinate -dimsu'
