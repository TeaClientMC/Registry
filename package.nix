{
  lib,
  buildDynamicCrate,
  stdenv,
  cmake,
}:
buildDynamicCrate {
  pname = "registry-cli";
  version = (lib.importTOML ./Cargo.toml).workspace.package.version;

  src = lib.cleanSource ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [ cmake ];
  env.AWS_LC_SYS_CMAKE_BUILDER = 1;

  postInstall = lib.optionalString stdenv.hostPlatform.isStatic ''
    mkdir -p $out/nix-support
    echo "file binary-dist $out/bin/registry-cli" >> $out/nix-support/hydra-build-products
  '';

  outputs = [ "registry-cli" ];

  meta = {
    description = "A Utility to Add Items to the TeaClient Registry.";
    homepage = "https://github.com/TeaClientMC/Registry";
    license = lib.licenses.gpl3;
  };
}
