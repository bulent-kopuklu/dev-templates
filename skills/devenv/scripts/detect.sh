#!/usr/bin/env bash
# Prints key=value facts about the project in the current directory.
set -u

any() { for f in "$@"; do [ -e "$f" ] && return 0; done; return 1; }

langs=()
[ -f Cargo.toml ] && langs+=(rust)
{ [ -f CMakeLists.txt ] || [ -f meson.build ]; } && langs+=(cpp)
[ -f go.mod ] && langs+=(go)
[ -f package.json ] && langs+=(node)
{ [ -f pom.xml ] || any build.gradle*; } && langs+=(java)
{ [ -f cmake-android ] || find . -maxdepth 6 -name AndroidManifest.xml -not -path '*/build/*' -print -quit 2>/dev/null | grep -q .; } && langs+=(android)
echo "langs=${langs[*]:-}"

remote=$(git remote get-url origin 2>/dev/null || true)
echo "remote=${remote}"
case "$remote" in
  ""|*bulent-kopuklu*|*bulentk*) echo "own=true" ;;
  *)                             echo "own=false" ;;
esac

echo "flake=$([ -f flake.nix ] && echo yes || echo no)"
echo "flake_ours=$(grep -q 'dev-templates.lib.mkEnv' flake.nix 2>/dev/null && echo yes || echo no)"
echo "envrc=$([ -f .envrc ] && echo yes || echo no)"
echo "rust_toolchain=$([ -f rust-toolchain.toml ] || [ -f rust-toolchain ] && echo yes || echo no)"
echo "clangd=$([ -f .clangd ] && echo yes || echo no)"
echo "clang_format=$(any .clang-format _clang-format && echo yes || echo no)"
echo "rustfmt=$(any rustfmt.toml .rustfmt.toml && echo yes || echo no)"
echo "golangci=$(any .golangci.y*ml .golangci.toml .golangci.json && echo yes || echo no)"
echo "biome=$(any biome.json biome.jsonc .prettierrc* && echo yes || echo no)"
echo "compile_db=$(any compile_commands.json build/compile_commands.json && echo yes || echo no)"
echo "claude_md=$([ -f CLAUDE.md ] && echo yes || echo no)"
echo "claude_dir=$([ -d .claude ] && echo yes || echo no)"
echo "lockfile=$(ls pnpm-lock.yaml package-lock.json yarn.lock bun.lock* 2>/dev/null | head -1)"
