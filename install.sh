#!/usr/bin/env bash
# Kurulum: bu depodaki araçları ve global CLAUDE.md'yi yerine KOPYALAR, ve
# sunucu tarafındaki araçları scp ile gönderir. Symlink değil kopya — depo
# silinse ya da taşınsa kurulu olan çalışmaya devam eder; buradaki bir
# değişiklik karşı tarafa ancak bu script yeniden koşunca geçer.
#
#   ./install.sh              hepsi
#   NO_PI=1 ./install.sh      sunucu adımını atla
#
# Yeniden çalıştırmak güvenlidir.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$config"

bindest="${BINDEST:-$HOME/.local/bin}"; mkdir -p "$bindest"
for tool in "$here"/bin/*; do
  rm -f "$bindest/$(basename "$tool")"          # eski bir symlink hedefine yazmasin
  install -m 755 "$tool" "$bindest/$(basename "$tool")"
  echo "kopyalandi: $bindest/$(basename "$tool")"
done

# Global CLAUDE.md burada duruyor cunku config dizini bir depo degil.
rm -f "$config/CLAUDE.md"
install -m 644 "$here/claude/CLAUDE.md" "$config/CLAUDE.md"
echo "kopyalandi: $config/CLAUDE.md"

# Sunucu tarafi: newrepo orada kosar, bin/newrepo onu ssh ile cagirir.
PI_HOST="${PI_HOST:-dietpi@mediagw.local}"
PI_BIN="${PI_BIN:-/home/dietpi/.local/bin}"
if [ "${NO_PI:-0}" = 1 ]; then
  echo "atlandi:    $PI_HOST (NO_PI=1)"
elif ssh -o ConnectTimeout=5 -o BatchMode=yes "$PI_HOST" "mkdir -p '$PI_BIN'" 2>/dev/null; then
  scp -q "$here"/pi/* "$PI_HOST:$PI_BIN/"
  ssh "$PI_HOST" "chmod 755 $PI_BIN/*"
  echo "kopyalandi: $PI_HOST:$PI_BIN/"
else
  echo "atlandi:    $PI_HOST erisilemiyor" >&2
fi
