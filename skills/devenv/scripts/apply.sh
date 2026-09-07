#!/usr/bin/env bash
# Applies dev-templates to the project in the current directory.
#
#   apply.sh --langs "rust cpp" [--targets "aarch64"] [--ref <flake-ref>]
#
# Nothing touches the repository: every created file is listed in
# .git/info/exclude (the user git-adds what they want later). The devshell is
# therefore shell.nix, since a flake only sees files git tracks. Existing files
# are never overwritten.
set -euo pipefail
. "$(dirname "$0")/common.sh"

langs=""; targets=""
while [ $# -gt 0 ]; do
  case "$1" in
    --langs)   langs="$2"; shift 2 ;;
    --targets) targets="$2"; shift 2 ;;
    --ref)     ref="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$langs" ] || { echo "--langs required" >&2; exit 2; }

[ -d .git ] || { git init -q && echo "created: .git"; }

# nix flake init marks what it writes intent-to-add; that is undone below
snapshot() { git status --porcelain --untracked-files=all 2>/dev/null | cut -c4- | sort; }
before=$(snapshot)

set_lists() {
  local file=$1 quoted
  quoted=$(for l in $langs; do printf '"%s" ' "$l"; done)
  sed -i "s|^\( *\)langs = \[.*\];|\1langs = [ ${quoted}];|" "$file"
  if [ -n "$targets" ]; then
    quoted=$(for t in $targets; do printf '"%s" ' "$t"; done)
    sed -i "s|^\( *\)targets = \[.*\];|\1targets = [ ${quoted}];|" "$file"
  fi
}

if [ -f flake.nix ] || [ -f shell.nix ]; then
  echo "kept:    $(ls flake.nix shell.nix 2>/dev/null | tr '\n' ' ')(theirs)"
else
  init shell
  rev=$(nix flake metadata "$ref" --json 2>/dev/null | jq -r '.revision // empty')
  if [ -n "$rev" ]; then
    sed -i "s|DEV_TEMPLATES_REV|${rev}|" shell.nix
  else
    sed -i "s|\"github:bulent-kopuklu/dev-templates/DEV_TEMPLATES_REV\"|\"${ref}\"|" shell.nix
  fi
  set_lists shell.nix
fi
[ -f .envrc ] || { echo "use nix" > .envrc; echo "created: .envrc"; }

for l in $langs; do
  case "$l" in
    cpp)  init cpp ;;
    rust) any .rustfmt.toml || init rust ;;
    node) any biome.json biome.jsonc .prettierrc* prettier.config.* || init node ;;
    go)   init go ;;
  esac
done

init claude
if [ -f CLAUDE.md ] && grep -q '^# PROJECT_NAME$' CLAUDE.md; then
  sed -i "s|^# PROJECT_NAME$|# $(basename "$PWD")|; s|^- Diller: LANGS$|- Diller: ${langs}|" CLAUDE.md
fi
chmod +x scripts/fmt.sh 2>/dev/null || true

after=$(snapshot)
new=$(comm -13 <(echo "$before") <(echo "$after"); echo ".direnv/")
if [ -n "$new" ]; then
  echo "$new" | xargs git reset -q -- 2>/dev/null || true
  { echo "# dev-templates (local only)"; echo "$new"; } >> .git/info/exclude
  echo "$new" | sed 's/^/excluded: /'
fi

command -v direnv >/dev/null && direnv allow . && echo "direnv: allowed"
