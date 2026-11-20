-- Your plugins and overrides. Every spec here is merged with LazyVim's.
-- Add language support with LazyVim extras: run :LazyExtras, or list them here, e.g.
--   { import = "lazyvim.plugins.extras.lang.go" },
return {
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.nix" },
  { import = "lazyvim.plugins.extras.lang.toml" },
}
