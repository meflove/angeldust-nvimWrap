{
  description = "Angeldust's neovim flake, built on nix-wrapper-modules (migrated from nixCats)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # the wrapper itself
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # newer-than-nixpkgs neovim
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # --- Lua tooling -------------------------------------------
    emmylua-ls = {
      url = "github:EmmyLuaLs/emmylua-analyzer-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Rust toolchain + tooling -------------------------------------------
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bacon-ls = {
      url = "github:crisidev/bacon-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rustowl = {
      url = "github:nix-community/rustowl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Nix tooling ---------------------------------------------------------
    statix = {
      url = "github:molybdenumsoftware/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Nushell LSP ---------------------------------------------------------
    nu-lint = {
      url = "git+https://codeberg.org/wvhulle/nu-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      url = "github:folke/flash.nvim/c92888d432bebeb145dad09c07ab65cc7c577184";
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

    plugins-triforce = {
      url = "github:gisketch/triforce.nvim";
      flake = false;
    };

    plugins-clangd-extensions = {
      url = "git+https://git.sr.ht/~chinmay/clangd_extensions.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
    ];

    # Overlays applied to the nixpkgs used to BUILD neovim, so that the extra
    # tools (fenix, bacon, statix, nu-lint, ...) are visible as `pkgs.<name>`
    # inside module.nix's `runtimePkgs`.
    dependencyOverlays = [
      inputs.fenix.overlays.default
      inputs.rustowl.overlays.default
      (import "${inputs.statix}/overlay.nix")
      (
        final: prev: let
          inherit (prev.stdenv.hostPlatform) system;
        in {
          # lua
          inherit
            (inputs.emmylua-ls.packages.${system})
            emmylua_ls
            emmylua_check
            ;
          emmylua_formatter = let
            src = inputs.emmylua-ls;
            cargoToml = fromTOML (builtins.readFile "${src}/crates/emmylua_formatter/Cargo.toml");
          in
            prev.rustPlatform.buildRustPackage {
              pname = cargoToml.package.name;
              version = cargoToml.package.version;
              inherit src;
              cargoLock.lockFile = src + "/Cargo.lock";
              buildAndTestSubdir = "crates/emmylua_formatter";
              strictDeps = true;
              # nativeBuildInputs = [ prev.pkg-config ];
              # buildInputs = [ prev.openssl ];
              # env.OPENSSL_NO_VENDOR = 1;
            };

          # rust
          bacon-ls = inputs.bacon-ls.defaultPackage.${system};
          fenix = prev.fenix.complete.withComponents [
            "cargo"
            "clippy"
            "rust-src"
            "rustc"
            "rustfmt"
          ];

          # nushell LSP (straight from its flake)
          nu-lint = inputs.nu-lint.packages.${system}.default;

          # nixpkgs-master channel (kept for ad-hoc use)
          master = import inputs.nixpkgs-master {
            inherit system;
            config = {
              inherit (final.config) allowBroken allowInsecure allowUnfree;
            };
          };

          # python-lsp-ruff fails its tests; relax it so pylsp can use it
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (
                _final: p: {
                  python-lsp-ruff = p.ruff.overrideAttrs (_old: {
                    doCheck = false;
                    pythonImportsCheck = [];
                  });
                }
              )
            ];
        }
      )
    ];

    # Build a pkgs set with our overlays + allowUnfree for a given system.
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = dependencyOverlays;
        config.allowUnfree = true;
      };

    eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (mkPkgs system));

    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;

    treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
    checks = eachSystem (pkgs: {
      formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
    });

    wrapperModules = {
      neovim = module;
      default = self.wrapperModules.neovim;
    };

    wrappers = {
      neovim = wrapper.config;
      default = self.wrappers.neovim;
    };

    overlays = {
      neovim = _final: prev: {
        neovim = self.wrappers.neovim.wrap {pkgs = mkPkgs prev.stdenv.hostPlatform.system;};
      };
      default = self.overlays.neovim;
    };

    packages = eachSystem (pkgs: {
      neovim = self.wrappers.neovim.wrap {inherit pkgs;};
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    });

    # when consumed via a NixOS/Home-Manager config, the dependencyOverlays
    # above must be applied to that config's nixpkgs for fenix/bacon/... to appear.
    nixosModules = {
      default = self.nixosModules.neovim;
      neovim = wrappers.lib.getInstallModule {
        name = "neovim";
        value = module;
      };
    };
    homeModules = {
      default = self.homeModules.neovim;
      neovim = self.nixosModules.neovim;
    };
  };
}
