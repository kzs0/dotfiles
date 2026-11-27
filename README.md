# dotfiles

Fish + Tide prompt everywhere. Ghostty, Rex, Zed, Claude Code, Codex, pi, gh, glab,
podman + k3d, Headroom, and a set of stable CLI utilities.

| | packages | configs |
|---|---|---|
| macOS | `Brewfile` (Homebrew) | `config/<app>` symlinked into `~/.config/<app>` |
| Linux (Ubuntu / NixOS) | `nix/packages.nix` via Home Manager (`flake.nix`) | same symlinks |

```
justfile            short menu of recipes (`just` lists them)
install.sh          bootstrap for a fresh machine
Brewfile            macOS packages
flake.nix, nix/     Linux packages (Home Manager)
config/<app>/       config files, symlinked file by file (bin → ~/.local/bin, pi → ~/.pi/agent)
scripts/<name>.sh   one script per component: install | remove | update
```

## New machine

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kzs0/dotfiles/main/install.sh)"
```

It ends in a setup wizard (arrow keys / `j` `k` to move, space to tick, enter to confirm):

1. **Components**: packages, fish + tide, fish as login shell, Neovim plugins, coding agents,
   Headroom, Rex, podman, macOS defaults.
2. **Languages**: Python, Go, Node.js, Rust via [mise](https://mise.jdx.dev), and the versions of each
   (`3.13 3.12`: several are fine, the first is the default).
3. **Cloud CLIs**: gcloud, aws, az (added to the Brewfile / Home Manager profile).
4. **A short command** (default `dots`) that runs recipes from any directory: `dots update`, `dots doctor`.

Choices are saved in `~/.config/dotfiles/install.env` (machine-local), so `just install` and `just update`
reuse them. Change them with `just configure`. `./install.sh --yes` / `just install --yes` skips the questions.

Then the interactive bits:

```sh
just auth                                 # gh + glab login, git credential helpers
just git-identity "Your Name" you@x.com   # stored in ~/.gitconfig (machine-local)
```

On Linux, `DOTFILES_PROFILE=desktop just install` also installs Ghostty + Zed from
nixpkgs (meant for NixOS; on Ubuntu use their upstream .deb/AppImage builds).

## Day to day

```sh
just                     # list recipes
just doctor              # what's linked / installed / missing
just update              # git pull + update the components you picked
just configure           # re-run the wizard (components, language versions, cloud CLIs, command)
just setup <component>   # (re)run one piece: packages fish nvim shell agents langs headroom rex podman shortcut macos
just remove <component>  # undo one piece, e.g. `just remove headroom`
just link zed            # (re)link one config;  just unlink zed
just k3d                 # dev cluster on podman;  just k3d-delete
dotfiles <recipe>        # same thing from any directory (fish function, tab-completes recipes)
dots <recipe>            # the shorter name you picked in the wizard
```

Each component is `scripts/<name>.sh install|remove|update`, so it's easy to read or run directly.

## Uninstall

```sh
just uninstall           # menu of what's installed (all ticked); untick what to keep
just uninstall --yes     # remove everything, packages included, without asking
just remove <component>  # just one piece
```

It goes in reverse order (packages last, keeping fish/just/git so the machine still works), restores the
default login shell, removes the language versions it added to mise and the shortcut command, and unlinks configs.

Files that existed before linking are moved to `~/.dotfiles-backup/<timestamp>/`.

## Editor & keys

- **Neovim + LazyVim** (`config/nvim`). `vim`/`vi` are aliased to `nvim` in fish. Plugin versions
  are pinned in `config/nvim/lazy-lock.json`; `just setup nvim` installs them, `just nvim-update` bumps them
  (commit the lockfile). Add languages with `:LazyExtras` or in `lua/plugins/user.lua`.
- **Mac-style keys** work the same in Ghostty, Rex, fish and nvim:

  | keys | does |
  |---|---|
  | ⌥← / ⌥→ | word back / forward |
  | ⌘← / ⌘→ | line start / end |
  | ⌥⌫ / ⌘⌫ | delete word / to line start |
  | ⇧ + any of the above, or ⇧←/→ | select (typing or ⌫ replaces the selection) |

  Ghostty (`config/ghostty/config`) and Rex (`config/rex/init.lua`) send standard key codes;
  `fish_user_key_bindings` and nvim's `lua/config/keymaps.lua` map them.

## Coding agents

- **claude / codex / pi** are all installed by `just setup agents`. pi defaults to the ChatGPT/Codex
  subscription (`/login` once in pi). Its config lives in `config/pi/` (→ `~/.pi/agent/`):
  plan mode (`/plan`), todos, `/handoff`, git checkpoints, a dangerous-command gate,
  protected paths (.env, .git), and desktop notifications.
- **Headroom** (`just setup headroom`) runs a local compression proxy on :8787 and routes
  Claude Code, Codex and pi through it. Usage beacon is off. `headroom dashboard` for savings,
  `set -x HEADROOM_SKIP 1` to bypass in one shell, `just remove headroom` to undo.

## Rex: resume after a server restart

Rex restores sessions/panes/cwds itself; `rex-resurrect` (a small daemon, `just setup rex`)
brings back what was *running* in each pane:

- Every 5s it asks Rex for each pane's foreground process. For agents it reads the live
  conversation id from the process (`~/.claude/sessions/<pid>.json`, `~/.codex/session-tags.jsonl`,
  pi's session file), so moving panes or `/resume`-ing is always reflected.
- When the server comes back, agents are resumed automatically (`claude --resume <id>`,
  `codex resume <id>`, `pi --session <file>`, safe flags kept, prompts never replayed). Other
  commands are typed into the pane but wait for Enter.
- `rex-resurrect status` shows what would be resumed; log in `~/.local/state/rex-resurrect/`.

## Adding things

- **CLI tool** → add to both `Brewfile` and `nix/packages.nix`.
- **Language** → mise handles most (`mise registry`); add it to the Languages menu in `scripts/setup.sh`.
- **Cloud CLI** → add to the cloud block in `Brewfile` and `nix/packages.nix`, and to the menu in `scripts/setup.sh`.
- **Component with setup steps** → add `scripts/<name>.sh` (copy an existing one), list it in `components` in the
  justfile and in `ORDER` + the Components menu in `scripts/setup.sh`.
- **Config file** → put it in `config/<app>/…` and run `just link`. New `config/<app>` dirs are picked up
  automatically; to link somewhere other than `~/.config/<app>`, add a `.link-target` file (path relative to `$HOME`).
- **Alias / abbr** → `config/fish/aliases.fish`. **Function** → `config/fish/functions/<name>.fish`.
- **Machine-specific / secrets** → `~/.config/fish/local.fish`, `~/.config/ghostty/local.conf`, `~/.gitconfig` (all untracked).

## Notes

- Prompt: Tide. Run `tide configure`, then `just prompt-save` to store the look in `config/fish/tide-style.fish`; `just setup fish` applies it on every machine. Needs a Nerd Font — Ghostty and Zed use JetBrainsMono Nerd Font.
- Rex: `just setup rex` installs the app on macOS (and adds it to Login Items so the server comes back after a
  reboot), plus its terminfo entry, Claude/Codex/pi skills and `rex-resurrect`. On Linux it skips the app; install
  Rex yourself. `rex-resurrect` installs as a systemd user service there, but has only been tested on macOS.
- k3d uses a rootful podman machine; `DOCKER_HOST` is exported in fish from the universal var `DOTFILES_PODMAN_SOCK`.
- Podman on Linux comes from the OS (`virtualisation.podman.enable` on NixOS, `apt install podman` on Ubuntu).
- NixOS: set the login shell declaratively (`programs.fish.enable = true; users.users.<you>.shell = pkgs.fish;`).

## Using this yourself

Fork it, then change what's personal:

- `install.sh` clones `kzs0/dotfiles`; set `DOTFILES_REPO=you/dotfiles` (or edit `REPO`) for your fork.
- Your git identity is never stored in the repo: `just git-identity "Name" email` writes `~/.gitconfig`.
- Prompt style (`config/fish/tide-style.fish`), keybindings and the pi defaults (`config/pi/settings.json`,
  which assumes a ChatGPT/Codex subscription) are mine; change or delete them.
- Run `just doctor` after `just install` to see what landed.

## License

[MIT](LICENSE)
