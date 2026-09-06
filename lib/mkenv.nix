{ rust-overlay }:

{ pkgs
, langs
, targets ? [ ]
, src ? null
, android ? { }
}:

let
  lib = pkgs.lib;
  has = l: builtins.elem l langs;

  crossPkgs = {
    aarch64 = pkgs.pkgsCross.aarch64-multiplatform;
    armv7 = pkgs.pkgsCross.armv7l-hf-multiplatform;
  };
  rustTriple = {
    aarch64 = "aarch64-unknown-linux-gnu";
    armv7 = "armv7-unknown-linux-gnueabihf";
  };
  crossFor = t: crossPkgs.${t} or (throw "dev-templates: unsupported target '${t}' (aarch64, armv7)");
  cross = map crossFor targets;

  linkerVar = triple: "CARGO_TARGET_${lib.toUpper (builtins.replaceStrings [ "-" ] [ "_" ] triple)}_LINKER";
  exportLinker = triple: path: ''export ${linkerVar triple}="${path}"'';

  crossLinkerExports = map
    (t: let cc = (crossFor t).stdenv.cc; in exportLinker rustTriple.${t} "${cc}/bin/${cc.targetPrefix}cc")
    targets;

  androidCfg = {
    api-level = 21;
    ndk-version = "23.2.8568313";
    cmake-version = "3.22.1";
    platforms = [ ];
    build-tools = [ ];
  } // android;

  androidTriples = {
    "aarch64-linux-android" = "aarch64-linux-android";
    "x86_64-linux-android" = "x86_64-linux-android";
    "i686-linux-android" = "i686-linux-android";
    "armv7-linux-androideabi" = "armv7a-linux-androideabi";
  };
  ndkBin = "$ANDROID_HOME/ndk/${androidCfg.ndk-version}/toolchains/llvm/prebuilt/linux-x86_64/bin";
  androidLinkerExports = lib.mapAttrsToList
    (triple: clangPrefix: exportLinker triple "${ndkBin}/${clangPrefix}${toString androidCfg.api-level}-clang")
    androidTriples;

  rustPkgs = pkgs.extend rust-overlay.overlays.default;
  toolchainFile = if src == null then null else src + "/rust-toolchain.toml";
  rustToolchain =
    if toolchainFile != null && builtins.pathExists toolchainFile
    then rustPkgs.rust-bin.fromRustupToolchainFile toolchainFile
    else rustPkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      targets = map (t: rustTriple.${t}) targets
        ++ lib.optionals (has "android") (builtins.attrNames androidTriples);
    };

  llvm = pkgs.llvmPackages;
  jdk = pkgs.jdk21;

  androidPkgs = import pkgs.path {
    inherit (pkgs) system;
    config = { android_sdk.accept_license = true; allowUnfree = true; };
  };
  androidSdk = (androidPkgs.androidenv.composeAndroidPackages {
    platformVersions = [ (toString androidCfg.api-level) ] ++ androidCfg.platforms;
    buildToolsVersions = androidCfg.build-tools;
    ndkVersions = [ androidCfg.ndk-version ];
    cmakeVersions = [ androidCfg.cmake-version ];
    includeNDK = true;
    includeEmulator = false;
  }).androidsdk;

  sets = {
    rust = {
      packages = [ rustToolchain ] ++ map (p: p.stdenv.cc) cross;
      shellHook = lib.concatStringsSep "\n"
        (crossLinkerExports ++ lib.optionals (has "android") androidLinkerExports);
    };

    cpp = {
      # clang-tools first: its wrapped clangd knows the nix include paths and must shadow clang's own
      packages = [ llvm.clang-tools llvm.clang llvm.bintools llvm.lldb ]
        ++ (with pkgs; [ gdb cmake ninja pkg-config ccache ])
        ++ map (p: p.buildPackages.clang) cross;
      shellHook = ''
        export CC="${llvm.clang}/bin/clang"
        export CXX="${llvm.clang}/bin/clang++"
        export CMAKE_EXPORT_COMPILE_COMMANDS=ON
      '';
    };

    go = {
      packages = with pkgs; [ go gopls golangci-lint delve ];
      shellHook = ''
        export GOPATH="''${XDG_DATA_HOME:-$HOME/.local/share}/go"
        export GOBIN="$GOPATH/bin"
        export PATH="$GOBIN:$PATH"
      '';
    };

    node = {
      packages = with pkgs; [ nodejs pnpm biome ];
      shellHook = ''
        export NPM_CONFIG_PREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/npm"
        export NPM_CONFIG_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/npm"
      '';
    };

    java = {
      packages = [ jdk pkgs.maven pkgs.gradle ];
      shellHook = ''
        export JAVA_HOME="${jdk.home}"
      '';
    };

    android = {
      packages = [ androidSdk jdk pkgs.gradle ];
      shellHook = ''
        export ANDROID_USER_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/android"
        export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
        unset ANDROID_SDK_HOME
        export ANDROID_NDK_VERSION="${androidCfg.ndk-version}"
        export ANDROID_CMAKE_VERSION="${androidCfg.cmake-version}"
        export ANDROID_MIN_SDK="${toString androidCfg.api-level}"
        export JAVA_HOME="${jdk.home}"
        mkdir -p "$ANDROID_USER_HOME"
      '';
    };
  };

  # android linker exports reference $ANDROID_HOME, so the android hook must run before rust's
  order = [ "android" "cpp" "rust" "go" "node" "java" ];
  selected = map
    (l: sets.${l} or (throw "dev-templates: unknown lang '${l}' (${lib.concatStringsSep ", " order})"))
    (builtins.filter has order);
  unknown = builtins.filter (l: !(sets ? ${l})) langs;
in
if unknown != [ ] then throw "dev-templates: unknown lang(s) ${toString unknown}; known: ${toString order}"
else {
  packages = lib.concatMap (s: s.packages) selected;
  shellHook = lib.concatStringsSep "\n" (map (s: s.shellHook) selected);
}
