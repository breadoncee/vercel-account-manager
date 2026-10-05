#!/bin/sh

set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
mkdir -p "$scratch/bin" "$scratch/existing"

cat > "$scratch/bin/vercel" <<'EOF'
#!/bin/sh
for arg in "$@"; do
  [ "$arg" != invalid-team ] || exit 23
done
printf '[' >> "$MOCK_VERCEL_LOG"
printf '<%s>' "$@" >> "$MOCK_VERCEL_LOG"
printf ']\n' >> "$MOCK_VERCEL_LOG"
EOF
chmod +x "$scratch/bin/vercel"

export PATH="$scratch/bin:$PATH"
export VCM_HOME="$scratch/state"
export MOCK_VERCEL_LOG="$scratch/calls"

"$project_dir/bin/vcm" add personal --default >/dev/null
"$project_dir/bin/vcm" add work >/dev/null
[ "$("$project_dir/bin/vcm" current)" = work ]
"$project_dir/bin/vcm" team team-one
"$project_dir/bin/vcm" teams
"$project_dir/bin/vcm" use personal team-two >/dev/null
"$project_dir/bin/vcm" whoami
"$project_dir/bin/vcm" add legacy "$scratch/existing" >/dev/null
"$project_dir/bin/vcm" use work team-three >/dev/null

if "$project_dir/bin/vcm" use personal invalid-team >/dev/null 2>&1; then
  printf 'Expected an invalid team to fail.\n' >&2
  exit 1
fi
[ "$("$project_dir/bin/vcm" current)" = work ]

expected=$(printf '[<--global-config><%s><login>]\n[<--global-config><%s><switch><team-one>]\n[<--global-config><%s><teams><list>]\n[<switch><team-two>]\n[<whoami>]\n[<--global-config><%s><switch><team-three>]' \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work")
actual=$(cat "$MOCK_VERCEL_LOG")
[ "$actual" = "$expected" ] || {
  printf 'Unexpected Vercel command routing:\n%s\n' "$actual" >&2
  exit 1
}

VCM_INSTALL_DIR="$scratch/installed" "$project_dir/install.sh" >/dev/null
cmp -s "$project_dir/bin/vcm" "$scratch/installed/vcm"
[ -x "$scratch/installed/vcm" ]

printf 'All vcm checks passed.\n'
