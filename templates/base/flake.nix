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
      android = { };  # api-level = 21; ndk-version = "23.2.8568313"; cmake-version = "3.22.1";

      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAll (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          env = dev-templates.lib.mkEnv { inherit pkgs langs targets android; src = ./.; };
        in {
          default = pkgs.mkShell {
            packages = env.packages;
            shellHook = env.shellHook;
          };
        });
    };
}
