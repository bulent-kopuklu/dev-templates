#!/usr/bin/env bash
# Installs the Claude Code skills of this repo into ~/.claude/skills as symlinks,
# so a `git pull` here updates them in place. Safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
dest="${CLAUDE_HOME:-$HOME/.claude}/skills"
mkdir -p "$dest"

for skill in "$here"/skills/*/; do
  name=$(basename "$skill")
  target="$dest/$name"
  if [ -L "$target" ]; then
    ln -sfn "${skill%/}" "$target"; echo "updated: $target -> ${skill%/}"
  elif [ -e "$target" ]; then
    echo "skipped: $target exists and is not a symlink; remove it to install" >&2
  else
    ln -s "${skill%/}" "$target"; echo "linked:  $target -> ${skill%/}"
  fi
done
