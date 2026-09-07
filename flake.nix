{
  description = "Project templates and devshell library for nix flake init";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      template = dir: description: { path = ./templates/${dir}; inherit description; };
    in {
      templates = {
        base = template "base" "flake.nix (edit langs/targets), .envrc, .gitignore";
        shell = template "shell" "shell.nix pinned to a dev-templates rev + .envrc (use nix); for repos where flake.nix cannot be committed";
        cpp = template "cpp" ".clangd, .clang-format, .editorconfig";
        rust = template "rust" "rustfmt.toml";
        go = template "go" ".golangci.yml";
        node = template "node" "biome.json";
        android-native = template "android-native" "cmake-android helper, VSCode cmake tasks";
        init-cpp = template "init-cpp" "CMakeLists.txt + src/main.cpp for an empty project";
        claude = template "claude" "CLAUDE.md skeleton, .claude/settings.json with format hook, scripts/fmt.sh";
        default = self.templates.base;
      };

      lib.mkEnv = import ./lib/mkenv.nix { inherit rust-overlay; };
    };
}
