# dev-templates

Project scaffolding as `nix flake init` templates plus a devshell library.

```bash
nix flake init -t github:bulent-kopuklu/dev-templates#base    # flake.nix, .envrc, .gitignore
nix flake init -t github:bulent-kopuklu/dev-templates#cpp     # .clangd, .clang-format, .editorconfig
nix flake init -t github:bulent-kopuklu/dev-templates#rust    # rustfmt.toml
nix flake init -t github:bulent-kopuklu/dev-templates#go      # .golangci.yml
nix flake init -t github:bulent-kopuklu/dev-templates#node    # biome.json
nix flake init -t github:bulent-kopuklu/dev-templates#claude  # CLAUDE.md, .claude/rules/, .claude/skills/
nix flake init -t github:bulent-kopuklu/dev-templates#shell   # shell.nix + .envrc (use nix) when flake.nix cannot be committed
nix flake init -t github:bulent-kopuklu/dev-templates#init-cpp  # CMakeLists.txt + src/main.cpp for an empty project
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
`.cargo/config.toml`. Node follows `.nvmrc` / `.node-version` (`22` → `nodejs_22`), default is nixpkgs' `nodejs`; `bun` is the default package manager for new projects, pnpm/npm are used when their lockfile exists.

## Claude Code skill

`skills/devenv` drives the templates from inside any project or an empty folder:
`/devenv rust c++ --target aarch64` (or a menu when arguments are missing), then
detect, apply, init the language's own project files, and prove the editor will
be green. Install once (symlinks into `~/.claude/skills`, so `git pull` updates them):

```bash
./install.sh
```

`install.sh` kopyalar, symlink kurmaz: `bin/` → `~/.local/bin`, `templates/` →
`~/.local/share/dev-templates/templates`. `devenv` şablonları önce depoda
(`<kök>/templates`), yoksa oradan okur — klondan çalıştırmak da kurulu hâli
kullanmak da çalışır.

## Repos on the git server

`pi/newrepo` runs on the server, `bin/newrepo` runs on the laptop and calls it over ssh.
`install.sh` copies both into place: the laptop side into `~/.local/bin`, the server side to
`dietpi@mediagw.local:/home/dietpi/.local/bin` over scp (`NO_PI=1` skips it). The laptop side
creates the bare repo and only prints the clone / fork-flow commands:

```bash
git config --global url."git@git.kopuklu.io:/mnt/storage/workspace/git-repos/".insteadOf "git.kopuklu.io:"
newrepo nats-bridge                               # empty repo
newrepo nats-bridge git@gitlab:grup/repo.git      # prints fork-flow wiring: origin = server, upstream = company
```
