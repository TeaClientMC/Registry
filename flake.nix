{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    cargo-dyndrv = {
      url = "github:obsidiansystems/cargo-dyndrv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bundlers = {
      url = "github:NixOS/bundlers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./hydraJobs.nix ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "aarch64-windows"
        "x86_64-windows"
        "x86_64-linux"
      ];
      perSystem =
        {
          lib,
          pkgs,
          system,
          config,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import inputs.rust-overlay)
              inputs.cargo-dyndrv.overlays.default
            ];
          };

          packages.registry-cli = pkgs.callPackage ./package.nix { };
          hydraJobs.registry-cli =
            inputs.bundlers.bundlers.${system}.toArx pkgs.pkgsStatic.callPackage ./package.nix
              { };

          devShells.default =
            with pkgs;
            let
              # Rust Toolchain
              toolchain = pkgs.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "x86_64-unknown-linux-gnu" ];
              };
            in
            mkShell {
              buildInputs = with pkgs; [
                ffmpeg_7
                pkg-config
              ];
              nativeBuildInputs =
                with pkgs;
                [
                  toolchain
                  openssl
                  (python3.withPackages (
                    p: with p; [
                      requests
                    ]
                  ))
                ]
                ++ lib.optionals stdenv.isLinux [
                  pkg-config
                ]
                ++ lib.optionals stdenv.isDarwin [
                  apple-sdk
                ];
              API_URL = "http://localhost:3000";
              RUSTFLAGS = "-C target-cpu=native -C linker=clang"; # TODO: Change when ldd is a linker in nixpkgs
            };
        };
    };
}
