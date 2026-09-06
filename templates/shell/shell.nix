# Devshell for a repository whose flake.nix cannot be committed (foreign project).
# nix-shell reads this file by path, so git never needs to know about it.
let
  dev = builtins.getFlake "github:bulent-kopuklu/dev-templates/DEV_TEMPLATES_REV";
  pkgs = dev.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};

  langs = [ ];    # rust cpp go node java android
  targets = [ ];  # aarch64 armv7
  android = { };  # api-level = 21; ndk-version = "23.2.8568313"; cmake-version = "3.22.1";

  env = dev.lib.mkEnv { inherit pkgs langs targets android; src = ./.; };
in
pkgs.mkShell {
  packages = env.packages;
  shellHook = env.shellHook;
}
