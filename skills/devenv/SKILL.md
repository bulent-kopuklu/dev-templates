---
name: devenv
description: Set up a project's Nix devshell, LSP and formatter configs, and Claude Code hooks from dev-templates so a fresh clone (or an empty folder) opens in VSCode with nothing red. Use for "/devenv", "ortamı kur", "bu rust projesi", or when a project has no flake.nix/.envrc.
---

# devenv

Goal: after this skill, `code .` from the devshell shows no errors in the editor. Files are copied from the dev-templates flake, never written by hand. Existing files are never touched.

Scripts: `~/.claude/skills/devenv/scripts/` (detect.sh, apply.sh, init.sh, verify.sh). Use them; do not reimplement their steps in prose.

## 1. Detect

Run `detect.sh` in the project root. Read every line.

- `own=false` → foreign repository: added files go to `.git/info/exclude`, nothing is committed, no style files are added, `shell.nix` replaces `flake.nix`.
- `langs=` is only a pre-selection for the menu, never a decision.

## 2. Menu (always)

One AskUserQuestion call with these questions, in this order. Arguments given with the command (`/devenv rust c++ arm64`) pre-select answers but the menu is still shown, so the user confirms everything in one place.

1. Languages, multi-select: rust, cpp, go, node, java, android. Pre-select detected ones. Aliases: `c++`/`cxx`/`c` → cpp; `ts`/`js`/`typescript` → node; `golang` → go.
2. Cross target, multi-select: aarch64, armv7, none. Aliases: `arm64` → aarch64; `arm`/`armv7l` → armv7. Never guess.
3. Android, only if `android` was chosen: API level (21 default) and NDK version (23.2.8568313 default); answers go into the `android = { ... };` line of flake.nix/shell.nix via apply.sh's output file (edit that single line by hand, nothing else).
4. Go module path, only if `go` was chosen and `go.mod` does not exist.

Foreign vs own is decided by detect, not by the user.

## 3. Apply

```
apply.sh --langs "<langs>" [--targets "<targets>"] [--foreign]
```

Creates `.git` if missing (own mode), the devshell, language dotfiles, `.claude/` with the format hook. Report the `created:` / `kept:` / `excluded:` lines verbatim.

`kept: .gitignore` → append the missing template entries to the existing file. This is the only file you edit by hand.

`flake_ours=no` and `flake=yes` → the project has its own devshell: leave it, still run verify inside it.

## 4. Init (new folder only)

When a chosen language has no project file (no Cargo.toml / CMakeLists.txt / go.mod / package.json):

```
direnv exec . ~/.claude/skills/devenv/scripts/init.sh --langs "<langs>" [--module <go module>]
```

Runs the language's own generator (cargo init, go mod init, pnpm init + typescript) or a template (`init-cpp`, `android-native`). `android` implies `cpp` and usually `rust`; select them too. Never write these files yourself.

## 5. Verify (green proof)

```
direnv exec . ~/.claude/skills/devenv/scripts/verify.sh "<langs>"
```

Runs the one-time steps that otherwise leave the editor red (cmake configure with compile db, cargo fetch, dependency install) then `cargo check`, `clangd --check`, `go vet`, `tsc --noEmit`.

- All `PASS`: done. Tell the user to open VSCode from this shell (`code .`).
- Any `FAIL`: report the printed cause and the fix. Typical: `go.mod` wants a newer Go than nixpkgs has; `rust-toolchain.toml` lacks a cross target (add it to that file, not to flake.nix). Do not declare success.

## 6. Own project finishing touches

Only when `own=true`: fill CLAUDE.md "Ortam" (build/test/lint commands) and "Yerleşim" from what the project contains, keep it short; `git add` the created files; do not commit unless asked.

## Never

- Write flake.nix, shell.nix, .clangd, CMakeLists.txt or formatter configs by hand.
- Change `langs`/`targets` in a flake.nix the project owned before this run.
- Force `-std=` or `-xc++` into a foreign project's .clangd.
- Commit in a foreign repository.
