{
  inputs,
  self,
  ...
}: let
  inherit ((import ./_overlay.nix {inherit inputs self;})) mkPkgs;
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # the wrapper tools (fenix, emmylua, pedantix, ...) must be visible in
    # the pkgs used for the wrapper, the formatter and the updater.
    _module.args.pkgs = mkPkgs system;

    legacyPackages.deps.kdl-lsp = pkgs.callPackage ../packages/kdl-lsp.nix {};

    packages.updater = pkgs.callPackage ../updater.nix {inherit self;};
  };
}
