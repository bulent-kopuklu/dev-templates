#!/usr/bin/env bash
# Bu dizindeki skill'leri global skills dizinine KOPYALAR ve oradakinin üstüne
# yazar. Symlink değil kopya: proje silinse de skill kalır, ve proje içinde
# düzenlenen bir skill global'e ancak bu script çağrılınca geçer.
#
#   .claude/skills/install.sh
#
# Yeniden çalıştırmak güvenlidir.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
mkdir -p "$dest"

for skill in "$here"/*/; do
  name=$(basename "$skill")
  [ -f "$skill/SKILL.md" ] || { echo "atlandi: $name (SKILL.md yok)" >&2; continue; }
  rm -rf "${dest:?}/$name"
  cp -r "${skill%/}" "$dest/$name"
  echo "kopyalandi: $dest/$name"
done
