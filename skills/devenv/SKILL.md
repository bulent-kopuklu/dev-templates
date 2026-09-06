---
name: devenv
description: Set up or repair a project's Nix devshell, LSP and formatter configs, and Claude Code hooks from dev-templates, so a fresh clone opens in VSCode with nothing red. Use when asked to set up the development environment ("ortamı kur", "devenv", "bu rust projesi"), or when a project has no flake.nix/.envrc.
---

# devenv

Goal: after this skill, `direnv allow` + `code .` from the devshell shows no errors in the editor. Files are copied from the dev-templates flake, never written by hand. Existing files are never touched.

Scripts live next to this file in `scripts/` (installed at `~/.claude/skills/devenv/scripts/`). Use them; do not reimplement their steps in prose.

## 1. Detect

Run `~/.claude/skills/devenv/scripts/detect.sh` in the project root. Read every line.

- `langs` is the proposal. If it is empty or looks wrong (e.g. a Makefile-only C project), ask the user.
- `own=false` means a foreign repository: added files go to `.git/info/exclude`, nothing is committed, and no style files (.clang-format, rustfmt.toml, ...) are added.
- Ask exactly one question if unknown: "cross target var mı? (aarch64, armv7, yok)". Never guess targets.

## 2. Apply

```
~/.claude/skills/devenv/scripts/apply.sh --langs "<langs>" [--targets "<targets>"] [--foreign]
```

Set `DEV_TEMPLATES_REF` to a local `path:` ref only when the user says the templates repo is not pushed yet. Report the `created:` / `kept:` / `excluded:` lines verbatim.

If `kept: .gitignore` appears, merge the template's entries the script printed into the existing file by appending only the missing lines. This is the single place where you edit a file by hand.

If `flake_ours=no` and `flake=yes`, the project has its own devshell: do not touch it, and run the verify step inside it anyway.

Foreign repositories get `shell.nix` + `use nix` instead of `flake.nix`: flakes require the file to be tracked by git, which a foreign repo must never see. The shell is pinned to the dev-templates revision current at apply time.

## 3. Verify (green proof)

```
direnv exec . ~/.claude/skills/devenv/scripts/verify.sh "<langs>"
```

`direnv exec` loads the same `.envrc` the editor will use, so a pass here is a pass for VSCode.

Runs the one-time steps that otherwise leave the editor red (cmake configure with compile db, cargo fetch, dependency install) and then the checks: `cargo check`, `clangd --check`, `go vet`, `tsc --noEmit`.

- All `PASS`: done. Tell the user to open VSCode from this shell (`code .`).
- Any `FAIL`: report the printed cause and the fix. Typical: `go.mod` needs a newer Go than nixpkgs provides; `rust-toolchain.toml` lacks a cross target (add the target to the file, not to flake.nix). Do not declare success.

## 4. Own project finishing touches

Only when `own=true`:
- Fill CLAUDE.md sections "Ortam" (build/test/lint commands) and "Yerleşim" from what the project actually contains. Keep the file short.
- `git add` the created files; do not commit unless asked.

## Never

- Write flake.nix, .clangd, or formatter configs by hand.
- Change `langs`/`targets` in a flake.nix the project owned before this run.
- Force `-std=` or `-xc++` flags into a foreign project's .clangd.
- Commit in a foreign repository.
