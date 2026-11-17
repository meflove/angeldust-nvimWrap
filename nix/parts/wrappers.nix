{
  inputs,
  self,
  ...
}: let
  inherit ((import ./_overlay.nix {inherit inputs self;})) mkPkgs;

  module = inputs.nixpkgs.lib.modules.importApply ../module.nix inputs;
in {
  imports = [
    inputs.wrappers.flakeModules.wrappers
  ];

  flake = {
    wrappers = {
      neovim = module;
      default = module;
    };

    overlays = {
      neovim = _final: prev: {
        neovim = self.wrappers.neovim.wrap {
          pkgs = mkPkgs prev.stdenv.hostPlatform.system;
        };
      };
      default = self.overlays.neovim;
    };

    nixosModules = {
      neovim = self.wrappers.neovim.install;
      default = self.wrappers.neovim.install;
    };
    homeModules = {
      neovim = self.wrappers.neovim.install;
      default = self.wrappers.neovim.install;
    };
  };
}
