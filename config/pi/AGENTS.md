# Global instructions for pi

- The user's shell is fish. Commands you run use bash, but anything you tell the user to paste should be fish-compatible.
- Prefer `rg` over grep, `fd` over find, and `jq`/`yq` for JSON/YAML. `gh` (GitHub) and `glab` (GitLab) are installed and authenticated.
- Containers run on podman (`docker` is aliased to it); local Kubernetes is k3d (`just k3d` in ~/dotfiles).
- Don't commit or push unless asked. Commits use the existing git identity.
