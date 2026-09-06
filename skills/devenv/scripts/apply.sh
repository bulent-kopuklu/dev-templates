#!/usr/bin/env bash
# Applies dev-templates to the project in the current directory.
#
#   apply.sh --langs "rust cpp" [--targets "aarch64"] [--foreign] [--ref <flake-ref>]
#
# Never overwrites an existing file (nix flake init refuses). With --foreign,
# every file this script creates is added to .git/info/exclude and only a
# minimal .clangd is written for cpp.
set -euo pipefail

ref="${DEV_TEMPLATES_REF:-github:bulent-kopuklu/dev-templates}"
langs=""; targets=""; foreign=no
while [ $# -gt 0 ]; do
  case "$1" in
    --langs)   langs="$2"; shift 2 ;;
    --targets) targets="$2"; shift 2 ;;
    --foreign) foreign=yes; shift ;;
    --ref)     ref="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$langs" ] || { echo "--langs required" >&2; exit 2; }

# nix flake init marks what it writes intent-to-add (shows as " A"); foreign mode undoes that below.
snapshot() { git status --porcelain --untracked-files=all 2>/dev/null | cut -c4- | sort; }
before=$(snapshot)

# nix flake init exits 1 when any file already exists; the rest is still written.
init() {
  nix flake init -t "${ref}#$1" 2>&1 | while IFS= read -r line; do
    case "$line" in
      wrote:*)     f=${line#wrote: \"}; f=${f%\"}; [ -d "$f" ] || echo "created: ${f#"$PWD"/}" ;;
      refusing*)   f=${line#refusing to overwrite existing file \"}; f=${f%\"}; echo "kept:    ${f#"$PWD"/}" ;;
    esac
  done || true
}

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
elif [ "$foreign" = yes ]; then
  # flakes need flake.nix tracked by git; a foreign repo must not see it, so use shell.nix instead
  init shell
  rev=$(nix flake metadata "$ref" --json 2>/dev/null | jq -r '.revision // empty')
  if [ -n "$rev" ]; then
    sed -i "s|DEV_TEMPLATES_REV|${rev}|" shell.nix
  else
    sed -i "s|\"github:bulent-kopuklu/dev-templates/DEV_TEMPLATES_REV\"|\"${ref}\"|" shell.nix
  fi
  set_lists shell.nix
else
  init base
  set_lists flake.nix
  sed -i "s|^  description = \"project\";|  description = \"$(basename "$PWD")\";|" flake.nix
fi
[ -f .envrc ] || { echo "use flake" > .envrc; echo "created: .envrc"; }

for l in $langs; do
  case "$l" in
    cpp)
      if [ "$foreign" = yes ]; then
        [ -f .clangd ] || { printf 'CompileFlags:\n  CompilationDatabase: build\n' > .clangd; echo "created: .clangd (minimal)"; }
      else
        init cpp
      fi ;;
    rust|go|node) [ "$foreign" = yes ] || init "$l" ;;
  esac
done

init claude
if [ -f CLAUDE.md ] && grep -q '^# PROJECT_NAME$' CLAUDE.md; then
  sed -i "s|^# PROJECT_NAME$|# $(basename "$PWD")|; s|^- Diller: LANGS$|- Diller: ${langs}|" CLAUDE.md
fi
chmod +x scripts/fmt.sh 2>/dev/null || true

if [ "$foreign" = yes ] && [ -d .git ]; then
  after=$(snapshot)
  new=$(comm -13 <(echo "$before") <(echo "$after"); echo ".direnv/")
  if [ -n "$new" ]; then
    echo "$new" | xargs git reset -q --
    { echo "# dev-templates (local only)"; echo "$new"; } >> .git/info/exclude
    echo "$new" | sed 's/^/excluded: /'
  fi
fi

command -v direnv >/dev/null && direnv allow . && echo "direnv: allowed"
