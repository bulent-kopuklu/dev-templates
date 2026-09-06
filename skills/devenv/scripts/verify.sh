#!/usr/bin/env bash
# Green proof per language. Run inside the devshell:  nix develop -c verify.sh "rust cpp"
set -u
langs="${1:?langs}"
fail=0
pass() { echo "PASS $1"; }
failed() { echo "FAIL $1: $2"; fail=1; }

for l in $langs; do
  case "$l" in
    rust)
      out=$(cargo fetch 2>&1 && cargo check --all-targets 2>&1) && pass rust || failed rust "$(echo "$out" | grep -m3 -i 'error')" ;;
    cpp)
      if [ -f CMakeLists.txt ] && [ ! -f build/compile_commands.json ]; then
        out=$(cmake -S . -B build -G Ninja 2>&1) || { failed cpp "cmake configure: $(echo "$out" | tail -3)"; continue; }
      fi
      src=$(find . -path ./build -prune -o \( -name '*.cpp' -o -name '*.cc' -o -name '*.c' \) -print 2>/dev/null | head -1)
      [ -n "$src" ] || { failed cpp "no source file found"; continue; }
      # --check also self-tests refactoring tweaks and counts their misses as errors; only real diagnostics matter
      diags=$(clangd --check="$src" 2>&1 | grep -E '^E\[[0-9:.]+\] \[[a-z_]+\] Line ')
      if [ -z "$diags" ]; then pass cpp; else failed cpp "$(echo "$diags" | head -3)"; fi ;;
    go)
      out=$(go mod download 2>&1 && go vet ./... 2>&1) && pass go || failed go "$(echo "$out" | head -3)" ;;
    node)
      if   [ -f pnpm-lock.yaml ]; then inst="pnpm install --frozen-lockfile"
      elif [ -f package-lock.json ]; then inst="npm ci"
      else inst="npm install"; fi
      out=$($inst 2>&1) || { failed node "$(echo "$out" | tail -3)"; continue; }
      if [ -f tsconfig.json ]; then
        out=$(npx tsc --noEmit 2>&1) && pass node || failed node "$(echo "$out" | head -3)"
      else pass node; fi ;;
    *) pass "$l (no check)" ;;
  esac
done
exit $fail
