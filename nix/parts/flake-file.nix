{inputs, ...}: {
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file = {
    outputs =
      # nix
      ''
        inputs:
          inputs.flake-parts.lib.mkFlake {inherit inputs;}
          (inputs.import-tree ./nix/parts)
      '';
    description = "Angeldust's neovim flake, built on nix-wrapper-modules (migrated from nixCats)";
    auto-follow.enable = true;

    nixConfig = {
      extra-substituters = [
        "https://meflove.cachix.org"
      ];
      extra-trusted-public-keys = [
        "meflove.cachix.org-1:daXeLaZBNNJOngNUDEoylRfvtai2uSFOqdg29fN+7N8="
      ];
    };

    style.sortPriority.flake = [
      "description"
      "nixConfig"
      "inputs"
      "outputs"
    ];

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      nixpkgs-lib.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      nixpkgs-master.url = "github:nixos/nixpkgs";

      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";

      # the wrapper itself
      wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

      # newer-than-nixpkgs neovim
      neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

      # --- Lua tooling -------------------------------------------
      emmylua-ls.url = "github:EmmyLuaLs/emmylua-analyzer-rust";

      # --- Rust toolchain + tooling -------------------------------------------
      fenix.url = "github:nix-community/fenix";
      bacon-ls.url = "github:crisidev/bacon-ls";
      rustowl.url = "github:nix-community/rustowl-flake";

      # --- Nix tooling ---------------------------------------------------------
      statix.url = "github:molybdenumsoftware/statix";
      pedantix.url = "github:swarsel/pedantix";

      # --- Nushell LSP ---------------------------------------------------------
      nu-lint.url = "git+https://codeberg.org/wvhulle/nu-lint";
    };
  };
}
