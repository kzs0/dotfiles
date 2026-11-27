# kzs0 dotfiles — run `just install` on a new machine, `just` to see this list.
# `just install` opens a wizard to pick components, language versions and cloud CLIs;
# the choices are saved in ~/.config/dotfiles/install.env (machine-local).
#
# Each component is a script in scripts/<name>.sh with install / remove / update:
#   packages  Brewfile (macOS) or nix/packages.nix via Home Manager (Linux)
#   fish      fisher plugins + saved tide prompt        shell    fish as login shell
#   nvim      LazyVim plugins (pinned lockfile)         agents   claude, codex, pi
#   headroom  token-compression proxy                   rex      Rex app + rex-resurrect
#   podman    container VM/socket for k3d               macos    optional macOS defaults
#   langs     python/go/node/rust versions via mise     shortcut short `dots`-style command
# Configs in config/<app> are symlinked into place by scripts/link.sh.

set shell := ["bash", "-euo", "pipefail", "-c"]

s := justfile_directory() / "scripts"
components := "packages fish nvim shell agents langs headroom rex podman shortcut macos"

# list recipes
default:
    @just --list --unsorted

# set up this machine: wizard, then install what you picked (safe to re-run; --yes: no questions)
install *flags: link
    {{s}}/setup.sh install {{flags}}

# re-run the setup wizard (components, languages, cloud CLIs, command name) without installing
configure:
    {{s}}/setup.sh configure

# remove what install set up: pick in a menu (--yes: everything, packages included)
uninstall *flags:
    {{s}}/setup.sh uninstall {{flags}}

# pull the repo and update the components this machine picked
update:
    git -C {{justfile_directory()}} pull --rebase --autostash
    {{s}}/link.sh link
    {{s}}/setup.sh update

# show what's linked, installed and missing
doctor:
    {{s}}/doctor.sh

# set up one component, e.g. `just setup rex`
setup component:
    @test -x {{s}}/{{component}}.sh || { echo "unknown component '{{component}}' — one of: {{components}}"; exit 1; }
    {{s}}/{{component}}.sh install

# remove one component, e.g. `just remove headroom`
remove component:
    @test -x {{s}}/{{component}}.sh || { echo "unknown component '{{component}}' — one of: {{components}}"; exit 1; }
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
