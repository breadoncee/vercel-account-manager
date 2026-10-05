#!/bin/sh

set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
mkdir -p "$scratch/bin" "$scratch/project/app" "$scratch/outside"

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

vcm() { "$project_dir/bin/vcm" "$@"; }

cd "$scratch/outside"
vcm add personal --default >/dev/null
vcm add work >/dev/null
vcm use --global personal team-two >/dev/null
[ "$(vcm current)" = personal ]

cd "$scratch/project"
project_canonical=$(pwd -P)
vcm use work team-one >/dev/null
[ "$(vcm current)" = work ]
[ "$(vcm current --global)" = personal ]
[ "$(cat .vcmrc)" = "$(printf 'account=work\nteam=team-one')" ]

cd app
vcm deploy
vcm teams
vcm team team-three >/dev/null
[ "$(cat ../.vcmrc)" = "$(printf 'account=work\nteam=team-three')" ]
vcm whoami
vcm deploy --scope override
case $(vcm status) in
  *"Source: $project_canonical/.vcmrc"*) ;;
  *) printf 'Expected project config to be effective.\n' >&2; exit 1 ;;
esac

cd "$scratch/outside"
[ "$(vcm current)" = personal ]
vcm deploy
vcm use --global work team-four >/dev/null
[ "$(vcm current)" = work ]
if vcm use --global personal invalid-team >/dev/null 2>&1; then
  printf 'Expected an invalid Vercel team to fail.\n' >&2
  exit 1
fi
[ "$(vcm current)" = work ]

cd "$scratch/project/app"
vcm deploy
vcm team --global team-five
[ "$(cat ../.vcmrc)" = "$(printf 'account=work\nteam=team-three')" ]

expected=$(printf '[<--global-config><%s><login>]\n[<switch><team-two>]\n[<--global-config><%s><--scope><team-one><deploy>]\n[<--global-config><%s><teams><list>]\n[<--global-config><%s><--scope><team-three><whoami>]\n[<--global-config><%s><deploy><--scope><override>]\n[<deploy>]\n[<--global-config><%s><switch><team-four>]\n[<--global-config><%s><--scope><team-three><deploy>]\n[<--global-config><%s><switch><team-five>]' \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work" \
  "$scratch/state/auth/work")
actual=$(cat "$MOCK_VERCEL_LOG")
[ "$actual" = "$expected" ] || {
  printf 'Unexpected Vercel command routing:\n%s\n' "$actual" >&2
  exit 1
}

mkdir -p "$scratch/bad"
printf 'account=work\naccount=personal\n' > "$scratch/bad/.vcmrc"
cd "$scratch/bad"
if vcm status >/dev/null 2>&1; then
  printf 'Expected malformed project config to fail.\n' >&2
  exit 1
fi

VCM_INSTALL_DIR="$scratch/installed" "$project_dir/install.sh" >/dev/null
cmp -s "$project_dir/bin/vcm" "$scratch/installed/vcm"
[ -x "$scratch/installed/vcm" ]

printf 'All vcm checks passed.\n'
