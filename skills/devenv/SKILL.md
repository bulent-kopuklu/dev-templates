---
name: devenv
description: Set up a project's Nix devshell, LSP and formatter configs, and Claude Code hooks from dev-templates so a fresh clone (or an empty folder) opens in VSCode with nothing red. Use for "/devenv", "ortamı kur", "bu rust projesi", or when a project has no flake.nix/.envrc.
---

# devenv

Goal: after this skill, `code .` from the devshell shows no errors in the editor. Files are copied from the dev-templates flake, never written by hand. Existing files are never touched, and nothing is added to git: every created file lands in `.git/info/exclude`; the user `git add`s what they want to keep. The devshell is `shell.nix` (`use nix`), pinned to the dev-templates revision current at apply time, because a flake only sees files git tracks.

Scripts: `~/.claude/skills/devenv/scripts/` (detect.sh, apply.sh, init.sh, verify.sh). Use them; do not reimplement their steps in prose.

## 1. Detect

Run `detect.sh` in the project root. Read every line.

- `build_system=defne|make|none` with `cpp` → there is no CMake; clangd needs a compile database the build tool does not emit. verify tells how (`bear`).
- `langs=` is only a pre-selection for the menu, never a decision.

## 2. Menu (always)

One AskUserQuestion call with these questions, in this order. Arguments given with the command (`/devenv rust c++ arm64`) pre-select answers but the menu is still shown, so the user confirms everything in one place.

1. Languages, multi-select: rust, cpp, go, node, java, android. Pre-select detected ones. Aliases: `c++`/`cxx`/`c` → cpp; `ts`/`js`/`typescript` → node; `golang` → go.
2. Cross target, multi-select: aarch64, armv7, none. Aliases: `arm64` → aarch64; `arm`/`armv7l` → armv7. Never guess.
3. Android, only if `android` was chosen: API level (21 default) and NDK version (23.2.8568313 default); answers go into the `android = { ... };` line of shell.nix (edit that single line by hand, nothing else).
4. Go module path, only if `go` was chosen and `go.mod` does not exist.
5. Node major version (20, 22, 24), only if `node` was chosen and neither `.nvmrc` nor `.node-version` exists. Write the answer to `.nvmrc` (e.g. `22`), add it to `.git/info/exclude`, and run `direnv reload` (nix-direnv only watches shell.nix/.envrc); the devshell picks `nodejs_<major>` from it. Older projects with native modules (better-sqlite3 and friends) usually need 20 or 22.


## 3. Apply

```
apply.sh --langs "<langs>" [--targets "<targets>"]
```

Creates `.git` if missing, `shell.nix` + `.envrc`, language dotfiles, `.claude/` with the format hook, and excludes all of it from git. Report the `created:` / `kept:` / `excluded:` lines verbatim.

`flake=yes` or an existing `shell.nix` → the project has its own devshell: leave it, still run verify inside it.

## 4. Init (new folder only)

When a chosen language has no project file (no Cargo.toml / CMakeLists.txt / go.mod / package.json):

```
direnv exec . ~/.claude/skills/devenv/scripts/init.sh --langs "<langs>" [--module <go module>]
```

Runs the language's own generator (cargo init, go mod init, bun init) or a template (`init-cpp`, `android-native`). `android` implies `cpp` and usually `rust`; select them too. Never write these files yourself.

## 5. Verify (green proof)

```
direnv exec . ~/.claude/skills/devenv/scripts/verify.sh "<langs>"
```

Runs the one-time steps that otherwise leave the editor red (cmake configure with compile db, cargo fetch, dependency install: bun by default, pnpm/npm when their lockfile exists) then `cargo check`, `clangd --check`, `go vet`, `tsc --noEmit`.

- All `PASS`: done. Tell the user to open VSCode from this shell (`code .`).
- Any `FAIL`: report the printed cause and the fix. Typical: `go.mod` wants a newer Go than nixpkgs has; `rust-toolchain.toml` lacks a cross target (add it to that file, not to flake.nix). Do not declare success.

## 6. Finishing touches

Fill CLAUDE.md "Ortam" (build/test/lint commands) and "Yerleşim" from what the project contains, keep it short. Remind the user that everything is local-only and which files to `git add` if they want them in the repo.

## Never

- Write flake.nix, shell.nix, .clangd, CMakeLists.txt or formatter configs by hand.
- Change `langs`/`targets` in a flake.nix or shell.nix the project owned before this run.
- `git add` or commit anything.
