# dev-templates

Project scaffolding as `nix flake init` templates plus a devshell library.

```bash
nix flake init -t github:bulent-kopuklu/devenv#base    # flake.nix, .envrc, .gitignore
nix flake init -t github:bulent-kopuklu/devenv#cpp     # .clangd, .clang-format, .editorconfig
nix flake init -t github:bulent-kopuklu/devenv#rust    # rustfmt.toml
nix flake init -t github:bulent-kopuklu/devenv#go      # .golangci.yml
nix flake init -t github:bulent-kopuklu/devenv#node    # biome.json
nix flake init -t github:bulent-kopuklu/devenv#claude  # CLAUDE.md, .claude/rules/, .claude/skills/
nix flake init -t github:bulent-kopuklu/devenv#make    # root Makefile driving components/<name>/
nix flake init -t github:bulent-kopuklu/devenv#shell   # shell.nix + .envrc (use nix) when flake.nix cannot be committed
nix flake init -t github:bulent-kopuklu/devenv#init-cpp  # CMakeLists.txt + src/main.cpp for an empty project
```

Language rules for the agent live in `templates/rules/<lang>.md`. For every
language it is given, `devenv` copies the matching file to the project's
`.claude/rules/` and imports it from the project's `CLAUDE.md`.

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

## Layout and the root Makefile

Code lives under `components/<name>/`, one language per component, its manifest
(`go.mod`, `Cargo.toml`, `CMakeLists.txt`, `package.json`) inside it. The root
`Makefile` reads each component's language from that manifest, so a new
component is just a new directory. Gradle (java, android) is not driven.

```bash
make                                   # build, VARIANT=debug TARGET=host
make build VARIANT=release TARGET=aarch64
make test COMPONENTS="api agent"       # test is host-only
make build-agent                       # one component; also test-<name>, lint-<name>
make dist TARGET=armv7                 # release build → dist/armv7/
make clean                             # build/
make distclean                         # + dist/, components/*/{node_modules,target}
```

Output goes to `build/<target>/<variant>/bin`. With `--speckit`, `devenv` also
replaces Companion's `plan-doc` node so a plan places its paths in this layout
instead of Spec Kit's `src/` default; the rule itself is in the `CLAUDE.md`
template under `## Yerleşim`.

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
