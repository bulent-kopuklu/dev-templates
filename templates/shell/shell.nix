# Devshell for a repository whose flake.nix cannot be committed (foreign project).
# nix-shell reads this file by path, so git never needs to know about it.
let
  dev = builtins.getFlake "github:bulent-kopuklu/dev-templates/DEV_TEMPLATES_REV";
  pkgs = dev.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};

  langs = [ ];    # rust cpp go node java android
  targets = [ ];  # aarch64 armv7

  env = dev.lib.mkEnv { inherit pkgs langs targets; src = ./.; };
in
pkgs.mkShell {
  packages = env.packages;
  shellHook = env.shellHook;
}
