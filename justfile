# kzs0 dotfiles — run `just install` on a new machine, `just` to see this list.
#
# Each component is a script in scripts/<name>.sh with install / remove / update:
#   packages  Brewfile (macOS) or nix/packages.nix via Home Manager (Linux)
#   fish      fisher plugins + saved tide prompt        shell    fish as login shell
#   nvim      LazyVim plugins (pinned lockfile)         agents   claude, codex, pi
#   headroom  token-compression proxy                   rex      Rex app, terminfo, skills
#   podman    container VM/socket for k3d               macos    optional macOS defaults
# Configs in config/<app> are symlinked into place by scripts/link.sh.

set shell := ["bash", "-euo", "pipefail", "-c"]

s := justfile_directory() / "scripts"
components := "packages fish nvim shell agents headroom rex podman"

# list recipes
default:
    @just --list --unsorted

# set up this machine (safe to re-run)
install: link
    for c in {{components}}; do {{s}}/$c.sh install; done
    @echo "✔ done. Next: 'just auth' and 'just git-identity \"Name\" email', then open a new terminal."

# undo install; packages stay (remove them with `just remove packages`)
uninstall:
    for c in rex headroom shell fish; do {{s}}/$c.sh remove; done
    {{s}}/link.sh unlink

# pull the repo and update every component
update:
    git -C {{justfile_directory()}} pull --rebase --autostash
    {{s}}/link.sh link
    for c in {{components}}; do {{s}}/$c.sh update; done

# show what's linked, installed and missing
doctor:
    {{s}}/doctor.sh

# set up one component, e.g. `just setup rex`
setup component:
    @test -x {{s}}/{{component}}.sh || { echo "unknown component '{{component}}' — one of: {{components}} macos"; exit 1; }
    {{s}}/{{component}}.sh install

# remove one component, e.g. `just remove headroom`
remove component:
    @test -x {{s}}/{{component}}.sh || { echo "unknown component '{{component}}' — one of: {{components}} macos"; exit 1; }
    {{s}}/{{component}}.sh remove

# symlink configs (all, or e.g. `just link zed`)
link *apps:
    {{s}}/link.sh link {{apps}}

# remove config symlinks (all, or e.g. `just unlink zed`)
unlink *apps:
    {{s}}/link.sh unlink {{apps}}

# log in to GitHub and GitLab and use them as git credential helpers
auth:
    gh auth status >/dev/null 2>&1 || gh auth login --git-protocol https --web
    gh auth setup-git
    glab auth status >/dev/null 2>&1 || glab auth login --hostname gitlab.com --web
    @echo "codex: run 'codex' once to sign in · pi: run 'pi', then /login"

# set this machine's git identity (stored in ~/.gitconfig, not the repo)
git-identity name email:
    git config --global user.name "{{name}}"
    git config --global user.email "{{email}}"

# save your current tide prompt (after `tide configure`) for every machine
prompt-save:
    {{s}}/fish.sh save-prompt

# update neovim plugins and the pinned lockfile (commit it)
nvim-update:
    {{s}}/nvim.sh update

# create a local k3d cluster on podman
k3d name="dev" agents="1":
    DOCKER_HOST="unix://$(fish -c 'echo $DOTFILES_PODMAN_SOCK')" k3d cluster create {{name}} --agents {{agents}} -p "8080:80@loadbalancer" --wait
    kubectl config use-context k3d-{{name}}

# delete a k3d cluster
k3d-delete name="dev":
    DOCKER_HOST="unix://$(fish -c 'echo $DOTFILES_PODMAN_SOCK')" k3d cluster delete {{name}}

# TEMPORARY: remove the old rex-resurrect daemon (Rex restores pane programs itself now)
rex-resurrect-cleanup:
    {{s}}/rex-resurrect-cleanup.sh
