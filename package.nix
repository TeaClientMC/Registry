{
  lib,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage {
  pname = "registry-cli";
  version = (lib.importTOML ./Cargo.toml).workspace.package.version;

  src = lib.cleanSource ./.;

  cargoLock.lockFile = ./Cargo.lock;

  postInstall = lib.optionalString stdenv.hostPlatform.isStatic ''
    mkdir -p $out/nix-support
    echo "file binary-dist $out/bin/registry-cli" >> $out/nix-support/hydra-build-products
  '';

  meta = {
    description = "A Utility to Add Items to the TeaClient Registry.";
    homepage = "https://github.com/TeaClientMC/Registry";
    license = lib.licenses.gpl3;
  };
}
