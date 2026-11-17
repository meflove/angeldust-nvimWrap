{
  flake-file.inputs = {
    # --- lazy-loading engine (fetched from source to always get the latest) ---
    # these two are already in nixpkgs, but pinning them here guarantees freshness.
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };

    # --- plugins fetched straight from source (auto-built via plugins-<name>) -
    # any input named `plugins-<name>` is picked up by `config.nvim-lib.pluginsFromPrefix`
    # in module.nix and becomes available as `config.nvim-lib.neovimPlugins.<name>`.
    plugins-tiny-inline-diagnostic = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };

    plugins-flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };

    plugins-blink-cmp-copilot = {
      url = "github:giuxtaposition/blink-cmp-copilot";
      flake = false;
    };

    plugins-bafa = {
      url = "github:mistweaverco/bafa.nvim";
      flake = false;
    };
    plugins-kikao = {
      url = "github:mistweaverco/kikao.nvim";
      flake = false;
    };

    plugins-neural-open = {
      url = "github:dtormoen/neural-open.nvim";
      flake = false;
    };

    plugins-ctags = {
      url = "github:wsdjeg/ctags.nvim";
      flake = false;
    };
    plugins-rooter = {
      url = "github:wsdjeg/rooter.nvim";
      flake = false;
    };
    plugins-job = {
      url = "github:wsdjeg/job.nvim";
      flake = false;
    };

    plugins-deltaview = {
      url = "github:kokusenz/deltaview.nvim";
      flake = false;
    };

    # FIXME: 404 error
    # plugins-triforce = {
    #   url = "github:gisketch/triforce.nvim";
    #   flake = false;
    # };

    plugins-clangd-extensions = {
      url = "git+https://git.sr.ht/~chinmay/clangd_extensions.nvim";
      flake = false;
    };
  };
}
