#!/usr/bin/env bash
# Claude Code PostToolUse hook: format the file that was just edited.
# Formatters come from the devshell; when one is missing the file is left as is.
set -u

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -n "$file" ] && [ -f "$file" ] || exit 0

have() { command -v "$1" >/dev/null 2>&1; }
any()  { for f in "$@"; do [ -e "$f" ] && return 0; done; return 1; }

case "$file" in
  *.rs)                            have rustfmt      && rustfmt --edition 2024 "$file" ;;
  *.c|*.cc|*.cpp|*.cxx|*.h|*.hpp)  have clang-format && clang-format -i "$file" ;;
  *.go)                            have gofmt        && gofmt -w "$file" ;;
  *.nix)                           have nixfmt       && nixfmt "$file" ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md|*.yaml|*.yml)
    if   any biome.json biome.jsonc;          then have biome && biome format --write "$file"
    elif any .prettierrc* prettier.config.*;  then have npx   && npx --no-install prettier --write "$file" >/dev/null
    fi ;;
  *.sh)                            have shfmt        && shfmt -w "$file" ;;
esac
exit 0
