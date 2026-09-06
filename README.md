# dev-templates

Project scaffolding as `nix flake init` templates plus a devshell library.

```bash
nix flake init -t github:bulent-kopuklu/dev-templates#base    # flake.nix, .envrc, .gitignore
nix flake init -t github:bulent-kopuklu/dev-templates#cpp     # .clangd, .clang-format, .editorconfig
nix flake init -t github:bulent-kopuklu/dev-templates#rust    # rustfmt.toml
nix flake init -t github:bulent-kopuklu/dev-templates#go      # .golangci.yml
nix flake init -t github:bulent-kopuklu/dev-templates#node    # biome.json
nix flake init -t github:bulent-kopuklu/dev-templates#claude  # CLAUDE.md, .claude/settings.json, scripts/fmt.sh
nix flake init -t github:bulent-kopuklu/dev-templates#shell   # shell.nix + .envrc (use nix) when flake.nix cannot be committed
```

Existing files are never overwritten. In the generated `flake.nix` edit two lines:

```nix
langs = [ "rust" "cpp" ];   # rust cpp go node java android
targets = [ "aarch64" ];    # aarch64 armv7
```

`lib.mkEnv { pkgs, langs, targets, src, android }` returns `{ packages, shellHook }`.
Rust comes from oxalica/rust-overlay; a `rust-toolchain.toml` in `src` wins over
the default stable toolchain (then it must list cross targets itself). Cross
linkers are exported as `CARGO_TARGET_<TRIPLE>_LINKER`, nothing is written to
`.cargo/config.toml`.

## Claude Code skill

`skills/devenv` drives the templates from inside any project: detect languages,
apply templates, prove the editor will be green. Install once:

```bash
ln -s "$PWD/skills/devenv" ~/.claude/skills/devenv
```
