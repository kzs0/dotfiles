# Headroom: route Claude Code / Codex through the local compression proxy.
# Only active on machines where `just setup headroom` deployed it (fish equivalent of
# the block `headroom deploy` writes into ~/.zshrc). Undo: `just remove headroom`.
# Per-shell opt-out: `set -x HEADROOM_SKIP 1` before launching an agent.

set -gx HEADROOM_TELEMETRY off # never send the usage beacon

if test -d $HOME/.headroom/deploy/default; and not set -q HEADROOM_SKIP
    set -q HEADROOM_PORT; or set -gx HEADROOM_PORT 8787
    set -gx HEADROOM_HOST 127.0.0.1
    set -gx HEADROOM_MODE cache
    set -gx HEADROOM_BACKEND anthropic
    set -gx ANTHROPIC_BASE_URL http://127.0.0.1:$HEADROOM_PORT
    set -gx OPENAI_BASE_URL http://127.0.0.1:$HEADROOM_PORT/v1
    set -gx ENABLE_TOOL_SEARCH true
end
