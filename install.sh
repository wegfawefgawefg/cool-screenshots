#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
src="$repo_root/bin/i3-screenshot"
dst_dir="$HOME/.local/bin"
dst="$dst_dir/i3-screenshot"

usage() {
  cat <<'EOF'
install.sh

Installs cool-screenshots to ~/.local/bin/i3-screenshot.

Options:
  --print-i3-snippet  Print the i3 snippet to stdout
  --append-i3         Append the snippet to ~/.config/i3/config (makes a timestamped backup)
EOF
}

print_snippet() {
  cat "$repo_root/i3/snippet.conf"
}

append_i3() {
  local cfg="${I3_CONFIG:-$HOME/.config/i3/config}"
  local marker="cool-screenshots i3 keybinds"

  if [[ ! -f "$cfg" ]]; then
    echo "install.sh: i3 config not found at $cfg" >&2
    echo "install.sh: set I3_CONFIG=... or create the file, then re-run with --append-i3" >&2
    exit 1
  fi

  if grep -q "$marker" "$cfg" 2>/dev/null; then
    echo "install.sh: snippet already present in $cfg (marker: $marker)"
    return 0
  fi

  local ts backup
  ts="$(date +%F_%H-%M-%S)"
  backup="${cfg}.bak.${ts}"
  cp -f "$cfg" "$backup"

  {
    echo ""
    echo "# --- $marker ---"
    cat "$repo_root/i3/snippet.conf"
    echo "# --- /$marker ---"
    echo ""
  } >>"$cfg"

  echo "install.sh: appended i3 snippet to $cfg"
  echo "install.sh: backup written to $backup"
}

main() {
  case "${1:-}" in
    "" )
      ;;
    --print-i3-snippet )
      print_snippet
      exit 0
      ;;
    --append-i3 )
      ;;
    -h|--help )
      usage
      exit 0
      ;;
    * )
      usage >&2
      exit 2
      ;;
  esac

  mkdir -p "$dst_dir"
  install -m 0755 "$src" "$dst"
  echo "install.sh: installed $dst"

  if [[ "${1:-}" == "--append-i3" ]]; then
    append_i3
  else
    echo "install.sh: next: add i3 keybinds from $repo_root/i3/snippet.conf and reload i3"
  fi
}

main "${1:-}"
