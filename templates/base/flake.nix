{
  description = "project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    dev-templates.url = "github:bulent-kopuklu/dev-templates";
    dev-templates.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, dev-templates }:
    let
      langs = [ ];    # rust cpp go node java android
      targets = [ ];  # aarch64 armv7

      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAll (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          env = dev-templates.lib.mkEnv { inherit pkgs langs targets; src = ./.; };
        in {
          default = pkgs.mkShell {
            packages = env.packages;
            shellHook = env.shellHook;
          };
        });
    };
}
