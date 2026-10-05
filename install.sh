#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: ./install.sh [--force]

Copies vcm to ~/.local/bin (or VCM_INSTALL_DIR, if set).
Use --force to replace an existing installation.
EOF
}

force=0
case ${1:-} in
  '') ;;
  --force) force=1 ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { usage >&2; exit 2; }

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_file=$source_dir/bin/vcm
install_dir=${VCM_INSTALL_DIR:-$HOME/.local/bin}
case $install_dir in
  /*) ;;
  *) printf 'VCM_INSTALL_DIR must be an absolute path.\n' >&2; exit 2 ;;
esac

mkdir -p "$install_dir"
target=$install_dir/vcm
if [ -e "$target" ] || [ -L "$target" ]; then
  if [ -f "$target" ] && cmp -s "$source_file" "$target"; then
    printf 'vcm is already installed at %s\n' "$target"
    exit 0
  fi
  if [ "$force" -ne 1 ]; then
    printf 'Existing file at %s. Run ./install.sh --force to replace it.\n' "$target" >&2
    exit 1
  fi
fi

install -m 755 "$source_file" "$target"
printf 'Installed vcm at %s\n' "$target"
case :$PATH: in
  *:"$install_dir":*) ;;
  *) printf 'Add this line to your shell setup, then open a new terminal:\n  export PATH="%s:$PATH"\n' "$install_dir" ;;
esac
