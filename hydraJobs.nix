{
  flake-parts-lib,
  lib,
  ...
}:
flake-parts-lib.mkTransposedPerSystemModule {
  name = "hydraJobs";
  file = ./hydraJobs.nix;
  option = lib.mkOption {
    description = "The `hydraJobs` flake output defines derivations to be built by the Hydra continuous integration system.";
    default = { };
    type =
      let
        hydraJobType = lib.types.lazyAttrsOf (lib.types.either lib.types.package hydraJobType);
      in
      hydraJobType;
  };
}
