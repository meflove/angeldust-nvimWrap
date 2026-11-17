# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Angeldust's neovim flake, built on nix-wrapper-modules (migrated from nixCats)";

  nixConfig = {
    extra-substituters = [ "https://meflove.cachix.org" ];
    extra-trusted-public-keys = [ "meflove.cachix.org-1:daXeLaZBNNJOngNUDEoylRfvtai2uSFOqdg29fN+7N8=" ];
  };

  inputs = {
    bacon-ls = {
      url = "github:crisidev/bacon-ls";
      inputs = {
        naersk.inputs.fenix.follows = "fenix";
        nixpkgs.follows = "nixpkgs";
      };
    };
    emmylua-ls = {
      url = "github:EmmyLuaLs/emmylua-analyzer-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file = {
      url = "github:denful/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    import-tree = {
      url = "github:denful/import-tree";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    nixpkgs-lib = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    nixpkgs-master = {
      url = "github:nixos/nixpkgs";
    };
    nu-lint = {
      url = "git+https://codeberg.org/wvhulle/nu-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pedantix = {
      url = "github:swarsel/pedantix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    plugins-bafa = {
      url = "github:mistweaverco/bafa.nvim";
      flake = false;
    };
    plugins-blink-cmp-copilot = {
      url = "github:giuxtaposition/blink-cmp-copilot";
      flake = false;
    };
    plugins-clangd-extensions = {
      url = "git+https://git.sr.ht/~chinmay/clangd_extensions.nvim";
      flake = false;
    };
    plugins-ctags = {
      url = "github:wsdjeg/ctags.nvim";
      flake = false;
    };
    plugins-deltaview = {
      url = "github:kokusenz/deltaview.nvim";
      flake = false;
    };
    plugins-flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    plugins-job = {
      url = "github:wsdjeg/job.nvim";
      flake = false;
    };
    plugins-kikao = {
      url = "github:mistweaverco/kikao.nvim";
      flake = false;
    };
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
    plugins-neural-open = {
      url = "github:dtormoen/neural-open.nvim";
      flake = false;
    };
    plugins-rooter = {
      url = "github:wsdjeg/rooter.nvim";
      flake = false;
    };
    plugins-tiny-inline-diagnostic = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    rustowl = {
      url = "github:nix-community/rustowl-flake";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    statix = {
      url = "github:molybdenumsoftware/statix";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt.follows = "treefmt";
      };
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix/parts);
}
