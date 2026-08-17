# neovim wrapper module — migrated from the nixCats categoryDefinitions/packageDefinitions
# scheme to the nix-wrapper-modules `config.specs` scheme.
#
# mapping summary (nixCats -> here):
#   lspsAndRuntimeDeps.<cat>  ->  config.specs.<cat>.runtimePkgs
#   startupPlugins.<cat>      ->  config.specs.<cat>.data  (lazy = false items)
#   optionalPlugins.<cat>     ->  config.specs.<cat>.data  (lazy = true items)
#   packageDefinitions categories.<cat> = true
#                             ->  config.specs.<cat>.enable  (defaults to true)
#   nixCats.extra.<x>         ->  config.specs.<cat>.mainInfo.<x>  (spec-specific,
#                                 collected into config.info by nvim-lib.nix)
#   neovim-unwrapped          ->  config.package
inputs: {
  wlib,
  pkgs,
  ...
}: {
  imports = [
    wlib.wrapperModules.neovim
    ./nvim-lib.nix
    ./general.nix
    ./langs.nix
  ];

  # makes `inputs` available to the imported modules' function args
  config._module.args.inputs = inputs;

  config = {
    # -------------------------------------------------------------- settings
    settings = {
      # provision the whole config dir (init.lua, lua/, after/) via nix.
      config_directory = ../.;

      colorscheme = "rose-pine-moon";

      # plain setting read via `nixInfo(false, "settings", "lspDebugMode")`
      lspDebugMode = false;
    };

    # neovim nightly
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

    # python3 / node / perl provider hosts
    hosts = {
      python3.nvim-host.enable = true;
      node.nvim-host.enable = true;
      perl.nvim-host.enable = true;
    };
  };
}
