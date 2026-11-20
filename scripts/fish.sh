#!/usr/bin/env bash
# fish plugins (fisher: tide, fzf.fish) and the saved tide prompt style.
. "$(dirname "$0")/lib.sh"

STYLE="$DOTFILES/config/fish/tide-style.fish"

install() {
  fish -c 'functions -q fisher; or curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher update'
  if [ -s "$STYLE" ]; then fish "$STYLE" && say "applied saved tide style"
  else say "no saved tide style: run 'tide configure', then 'just prompt-save'"; fi
}

remove() {
  fish -c 'functions -q fisher; and fisher remove (fisher list | string match -v jorgebucaran/fisher); fisher remove jorgebucaran/fisher' || true
}

# save the current tide look as the default for every machine
save-prompt() {
  fish -c 'echo "# tide style, saved by just prompt-save"; for v in (set -U --names | string match "tide_*"); echo set -U $v (string escape -- $$v); end' > "$STYLE"
  say "saved -> config/fish/tide-style.fish (commit it)"
}

main "$@"
