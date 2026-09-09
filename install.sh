#!/usr/bin/env bash
# Installs this repo's tools and the global CLAUDE.md as symlinks, so a `git pull`
# here updates them in place. Safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$config"

bindest="$HOME/.local/bin"; mkdir -p "$bindest"
for tool in "$here"/bin/*; do
  ln -sfn "$tool" "$bindest/$(basename "$tool")" && echo "linked:  $bindest/$(basename "$tool")"
done

# The global CLAUDE.md lives here so it is versioned; the config dir is not a repo.
src="$here/claude/CLAUDE.md"
target="$config/CLAUDE.md"
if [ -L "$target" ] || [ ! -e "$target" ]; then
  ln -sfn "$src" "$target"; echo "linked:  $target -> $src"
else
  echo "skipped: $target exists and is not a symlink; back it up and remove it to install" >&2
fi
