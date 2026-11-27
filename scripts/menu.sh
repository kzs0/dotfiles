# Tiny terminal UI for the setup wizard, sourced by setup.sh.
# Plain bash 3.2 (macOS /bin/bash runs this before Homebrew bash exists), no deps.
# Everything is drawn on /dev/tty, so callers can capture the answer from stdout.

# true when there's a terminal to ask questions on
has_tty() { [ -z "${CI:-}" ] && (exec </dev/tty) 2>/dev/null; }

# multiselect TITLE ITEM...   ITEM is "key|label|1" (checked) or "key|label|0".
# Prints the checked keys, space-separated. Exits 130 if cancelled (q / ctrl-c).
multiselect() {
  local title="$1"; shift
  local n=0 cur=0 i j rest key seq all saved
  local keys labels on; keys=(); labels=(); on=()
  for i in "$@"; do
    keys[n]="${i%%|*}"; rest="${i#*|}"; labels[n]="${rest%|*}"; on[n]="${rest##*|}"; n=$((n + 1))
  done

  saved="$(stty -g </dev/tty)"
  trap 'stty "$saved" </dev/tty; printf "\033[?25h\n" >/dev/tty; exit 130' INT TERM
  stty -echo -icanon </dev/tty
  printf '\033[?25l\033[1m%s\033[0m\n\033[2m  ↑/↓ or j/k move · space toggle · a all/none · enter confirm · q quit\033[0m\n' "$title" >/dev/tty

  _ms_draw() {
    for ((j = 0; j < n; j++)); do
      local ptr=' ' box='\033[2m[ ]\033[0m'
      [ "$j" = "$cur" ] && ptr='\033[36m❯\033[0m'
      [ "${on[j]}" = 1 ] && box='\033[32m[x]\033[0m'
      printf '\r\033[K %b %b %s\n' "$ptr" "$box" "${labels[j]}"
    done >/dev/tty
  }
  _ms_draw

  while :; do
    key=''; IFS= read -rsn1 -d '' key </dev/tty || true
    case "$key" in
      $'\033')
        seq=''; IFS= read -rsn2 -t 1 -d '' seq </dev/tty || true
        case "$seq" in
          '[A' | 'OA') cur=$(((cur + n - 1) % n)) ;;
          '[B' | 'OB') cur=$(((cur + 1) % n)) ;;
        esac ;;
      k) cur=$(((cur + n - 1) % n)) ;;
      j) cur=$(((cur + 1) % n)) ;;
      ' ' | x) if [ "${on[cur]}" = 1 ]; then on[cur]=0; else on[cur]=1; fi ;;
      a)
        all=1; for ((j = 0; j < n; j++)); do [ "${on[j]}" = 1 ] || all=0; done
        for ((j = 0; j < n; j++)); do on[j]=$((1 - all)); done ;;
      $'\n' | $'\r' | '') break ;;
      q | $'\004') stty "$saved" </dev/tty; printf '\033[?25h' >/dev/tty; exit 130 ;;
    esac
    printf '\033[%dA' "$n" >/dev/tty
    _ms_draw
  done

  stty "$saved" </dev/tty; printf '\033[?25h' >/dev/tty; trap - INT TERM
  local out=''
  for ((j = 0; j < n; j++)); do [ "${on[j]}" = 1 ] && out="$out ${keys[j]}"; done
  echo "${out# }"
}

# ask PROMPT DEFAULT — prints the answer, or DEFAULT when left empty
ask() {
  local a=''
  printf '%s \033[2m[%s]\033[0m ' "$1" "$2" >/dev/tty
  IFS= read -r a </dev/tty || true
  printf '%s\n' "${a:-$2}"
}

# yesno PROMPT — default yes
yesno() {
  local a=''
  printf '%s \033[2m[Y/n]\033[0m ' "$1" >/dev/tty
  IFS= read -r a </dev/tty || true
  case "$a" in n | N | no | No) return 1 ;; esac
}
