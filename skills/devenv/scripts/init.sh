#!/usr/bin/env bash
# Creates the language's own project files in an empty project. Run inside the
# devshell (direnv exec . init.sh ...) after apply.sh. Skips languages that
# already have their project file.
#
#   init.sh --langs "rust cpp" [--module <go module path>]
set -euo pipefail
. "$(dirname "$0")/common.sh"

langs=""; module=""
while [ $# -gt 0 ]; do
  case "$1" in
    --langs)  langs="$2"; shift 2 ;;
    --module) module="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$langs" ] || { echo "--langs required" >&2; exit 2; }
name=$(basename "$PWD")

for l in $langs; do
  case "$l" in
    rust)
      [ -f Cargo.toml ] && { echo "kept:    Cargo.toml"; continue; }
      cargo init --name "$name" --vcs none -q . && echo "init:    cargo ($name)" ;;
    cpp)
      [ -f CMakeLists.txt ] && { echo "kept:    CMakeLists.txt"; continue; }
      init init-cpp
      sed -i "s/PROJECT_NAME/${name}/g" CMakeLists.txt src/main.cpp ;;
    go)
      [ -f go.mod ] && { echo "kept:    go.mod"; continue; }
      [ -n "$module" ] || { echo "go needs --module <path>, e.g. github.com/bulent-kopuklu/${name}" >&2; exit 2; }
      go mod init "$module" 2>/dev/null && echo "init:    go mod ($module)"
      [ -f main.go ] || printf 'package main\n\nfunc main() {}\n' > main.go ;;
    node)
      [ -f package.json ] && { echo "kept:    package.json"; continue; }
      pnpm init >/dev/null && echo "init:    pnpm"
      init init-node
      pnpm add -D typescript @types/node >/dev/null && echo "init:    typescript"
      mkdir -p src; [ -f src/index.ts ] || echo 'export {};' > src/index.ts ;;
    android)
      [ -f cmake-android ] && { echo "kept:    cmake-android"; continue; }
      init android-native
      chmod +x cmake-android 2>/dev/null || true ;;
    *) echo "init:    $l (nothing to do)" ;;
  esac
done
