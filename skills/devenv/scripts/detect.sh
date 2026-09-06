#!/usr/bin/env bash
# Prints key=value facts about the project in the current directory.
set -u

langs=()
[ -f Cargo.toml ] && langs+=(rust)
{ [ -f CMakeLists.txt ] || [ -f meson.build ]; } && langs+=(cpp)
[ -f go.mod ] && langs+=(go)
[ -f package.json ] && langs+=(node)
{ [ -f pom.xml ] || ls build.gradle* >/dev/null 2>&1; } && langs+=(java)
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
echo "clang_format=$(ls .clang-format _clang-format >/dev/null 2>&1 && echo yes || echo no)"
echo "rustfmt=$(ls rustfmt.toml .rustfmt.toml >/dev/null 2>&1 && echo yes || echo no)"
echo "golangci=$(ls .golangci.y*ml .golangci.toml .golangci.json >/dev/null 2>&1 && echo yes || echo no)"
echo "biome=$(ls biome.json biome.jsonc .prettierrc* >/dev/null 2>&1 && echo yes || echo no)"
echo "compile_db=$(ls compile_commands.json build/compile_commands.json >/dev/null 2>&1 && echo yes || echo no)"
echo "claude_md=$([ -f CLAUDE.md ] && echo yes || echo no)"
echo "claude_dir=$([ -d .claude ] && echo yes || echo no)"
echo "lockfile=$(ls pnpm-lock.yaml package-lock.json yarn.lock bun.lock* 2>/dev/null | head -1)"
