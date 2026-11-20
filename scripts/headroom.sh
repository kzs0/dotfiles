#!/usr/bin/env bash
# Headroom: local context-compression proxy on :8787 for claude / codex / pi.
# Env vars for claude/codex live in config/fish/conf.d/20-headroom.fish.
. "$(dirname "$0")/lib.sh"

export HEADROOM_TELEMETRY=off
URL=http://127.0.0.1:8787
MODELS=~/.pi/agent/models.json   # pi reads endpoints from here, not env vars

install() {
  command -v headroom >/dev/null || uv tool install --python 3.13 "headroom-ai[all]"
  curl -fsS -m 3 "$URL/readyz" >/dev/null 2>&1 || headroom deploy --no-docker --no-telemetry --port 8787
  mkdir -p "$(dirname "$MODELS")"; [ -f "$MODELS" ] || echo '{}' > "$MODELS"
  jq --arg u "$URL" '.providers["openai-codex"].baseUrl = "\($u)/v1"
     | .providers.openai.baseUrl = "\($u)/v1" | .providers.anthropic.baseUrl = $u' "$MODELS" > "$MODELS.tmp"
  mv "$MODELS.tmp" "$MODELS"
  curl -fsS -m 10 --retry 5 --retry-connrefused "$URL/readyz" >/dev/null && say "proxy healthy on :8787"
}

update() { uv tool upgrade headroom-ai || true; install; }

remove() {
  command -v headroom >/dev/null && headroom install remove --profile default || true
  if [ -f "$MODELS" ]; then
    jq 'del(.providers["openai-codex"].baseUrl, .providers.openai.baseUrl, .providers.anthropic.baseUrl)
        | .providers |= with_entries(select(.value != {}))' "$MODELS" > "$MODELS.tmp" && mv "$MODELS.tmp" "$MODELS"
  fi
  say "removed (open a new shell to drop its env vars)"
}

main "$@"
