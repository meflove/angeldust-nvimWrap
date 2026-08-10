# neovim wrapper module — migrated from the nixCats categoryDefinitions/packageDefinitions
# scheme to the nix-wrapper-modules `config.specs` scheme.
#
# mapping summary (nixCats -> here):
#   lspsAndRuntimeDeps.<cat>  ->  config.specs.<cat>.runtimePkgs
#   startupPlugins.<cat>      ->  config.specs.<cat>.data  (lazy = false items)
#   optionalPlugins.<cat>     ->  config.specs.<cat>.data  (lazy = true items)
#   packageDefinitions categories.<cat> = true
#                             ->  config.specs.<cat>.enable  (defaults to true)
#   nixCats.extra.<x>         ->  config.info.<x>
#   neovim-unwrapped          ->  config.package
inputs: {
  config,
  wlib,
  lib,
  pkgs,
  options,
  ...
}: {
  imports = [wlib.wrapperModules.neovim];

  # ----------------------------------------------------------------- nvim-lib
  # makes inputs named `plugins-<name>` available as
  # `config.nvim-lib.neovimPlugins.<name_without_prefix>` (auto-built from source).
  options = {
    nvim-lib = {
      neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
      };
      pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default = prefix: inputs:
          lib.pipe inputs [
            builtins.attrNames
            (builtins.filter (s: lib.hasPrefix prefix s))
            (map (
              input: let
                name = lib.removePrefix prefix input;
              in {
                inherit name;
                value = config.nvim-lib.mkPlugin name inputs.${input};
              }
            ))
            builtins.listToAttrs
          ];
      };
    };

    # -------------------------------------------------------- colorscheme
    # a list of theme names (first one is used by default)
    settings.colorscheme = lib.mkOption {
      type = lib.types.str;
      default = "rose-pine";
    };
  };

  # -------------------------------------------------------------- settings
  config = {
    settings = {
      # provision the whole config dir (init.lua, lua/, after/) via nix.
      config_directory = ./.;

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

    # ------------------------------------------------------------ info
    # values handed to lua via `nixInfo(<default>, "info", ...)` (replaces nixCats.extra).
    # NOTE: nixos_options / home_manager_options must point at your SYSTEM flake,
    # not this neovim-config flake. Adjust the paths below if nixd option completion
    # for nixos/home-manager should work.
    info = {
      # luafmt from conform doesn't work
      emmylua_formatter_path = lib.getExe' pkgs.emmylua_formatter "luafmt";
      sqlite_lib = "${pkgs.sqlite.out}/lib/libsqlite3.so";
      nixdExtras = {
        # the exprs are evaluated by nixd itself, with its cwd at the workspace
        # root — so `toString ./.` resolves to the flake being edited, and the
        # first nixosConfigurations / homeConfigurations entry is picked without
        # hardcoding a hostname.
        nixpkgs = ''import ${pkgs.path} {}'';
        nixos_options = ''
          (let
            f = builtins.getFlake (toString ./.);
          in (builtins.getAttr (builtins.head (builtins.attrNames f.nixosConfigurations)) f.nixosConfigurations).options)'';
        home_manager_options = ''
          (let
            f = builtins.getFlake (toString ./.);
          in (builtins.getAttr (builtins.head (builtins.attrNames f.homeConfigurations)) f.homeConfigurations).options)'';
      };
    };

    # --------------------------- specMods: a `runtimePkgs` field on every spec
    # (from the tips-and-tricks section) so per-spec tools land on PATH, then
    # collect them — skipping disabled specs so disabling a category is clean.
    specMods = _: {
      options.runtimePkgs =
        options.runtimePkgs
        // {
          description = ''
            Packages to put on the wrapped neovim's PATH for this spec.
            Skipped when the spec is disabled.
          '';
        };
    };
    runtimePkgs =
      config.specCollect
      (acc: v: acc ++ lib.optionals (v.enable or true) (v.runtimePkgs or []))
      [];

    specs = {
      # ------------------------------------------------- lazy-loading engine
      # lze + lzextras, fetched from source (plugins-lze / plugins-lzextras inputs).
      # must be startup (lazy = false) so the engine is available before anything loads.
      lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      colorscheme = {
        lazy = false;
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins; {
            "catppuccin-macchiato" = catppuccin-nvim;
            "catppuccin-mocha" = catppuccin-nvim;
            "tokyonight-storm" = tokyonight-nvim;
            "rose-pine" = rose-pine;
            "rose-pine-moon" = rose-pine;
          }
        );
      };

      # ------------------------------------------------------------- general
      # the bulk of the editor: startup deps (lazy=false) + lazy-loaded plugins.
      general = {
        after = ["lze"];
        lazy = true; # default for children; startup items override below
        runtimePkgs = with pkgs; [
          universal-ctags
          ripgrep
          fd
          tree-sitter
          unzip
          ghostscript
          tectonic
          mermaid-cli
          sqlite
        ];
        data = with pkgs.vimPlugins;
        with config.nvim-lib.neovimPlugins; [
          # --- startup (always on rtp 'start') ---
          {
            data = plenary-nvim;
            lazy = false;
          }
          {
            data = mini-icons;
            lazy = false;
          }
          {
            data = nvim-web-devicons;
            lazy = false;
          }

          # --- LSP core ---
          nvim-lspconfig

          # --- completion ---
          luasnip
          cmp-cmdline
          blink-compat
          minuet-ai-nvim
          colorful-menu-nvim
          blink-pairs
          blink-cmp

          # --- editor ---
          which-key-nvim
          ts-comments-nvim
          flash
          hover-nvim

          # --- git ---
          gitsigns-nvim

          # --- treesitter ---
          nvim-treesitter.withAllGrammars
          nvim-treesitter-context
          nvim-treesitter-textobjects

          # --- ui ---
          lualine-nvim
          indent-blankline-nvim
          snacks-nvim
          marks-nvim
          todo-comments-nvim
          trouble-nvim
          nvzone-volt
          neural-open
          triforce
          tiny-cmdline-nvim

          # --- utilities ---
          tiny-inline-diagnostic
          bafa
          kikao
          deltaview
          ctags
          rooter
          job
          grug-far-nvim
        ];
      };

      # ----------------------------------------------- language / tool specs
      # each carries its own runtimePkgs (LSPs/formatters/linters) so disabling the
      # spec (`config.specs.<lang>.enable = false;`) removes both the plugins and
      # the tools from PATH. auto_enable in lua then silently skips the lze specs.
      lint = {
        lazy = true;
        runtimePkgs = with pkgs; [
          yamllint
          statix
          python3Packages.demjson3
        ];
        data = with pkgs.vimPlugins; [nvim-lint];
      };

      format = {
        lazy = true;
        runtimePkgs = with pkgs; [
          alejandra
          # stylua
          emmylua_formatter
          ruff
          yamlfmt
          yamlfix
          fixjson
          python3Packages.json-repair
        ];
        data = with pkgs.vimPlugins; [conform-nvim];
      };

      nix = {
        lazy = true;
        runtimePkgs = with pkgs; [
          nixd
          nil
        ];
        data = [];
      };

      lua = {
        lazy = true;
        runtimePkgs = with pkgs; [
          emmylua_ls
        ];
        data = with pkgs.vimPlugins; [lazydev-nvim];
      };

      python = {
        lazy = true;
        # ty = type checking LSP; ruff binary comes from the `format` spec
        # (its built-in LSP server powers ruff diagnostics).
        runtimePkgs = with pkgs; [
          ty
          ruff
        ];
        data = [];
      };

      bash = {
        lazy = true;
        runtimePkgs = with pkgs; [
          bash-language-server
          shfmt
          shellcheck
        ];
        data = [];
      };

      markdown = {
        lazy = true;
        runtimePkgs = with pkgs; [marksman];
        data = with pkgs.vimPlugins; [
          markdown-preview-nvim
          markview-nvim
        ];
      };

      rust = {
        lazy = true;
        runtimePkgs = with pkgs; [
          rust-analyzer-nightly
          graphviz
          fenix
          bacon-ls
          taplo
          rustowl
        ];
        data = with pkgs.vimPlugins; [
          crates-nvim
          rustaceanvim
          pkgs.rustowl-nvim
        ];
      };

      yaml = {
        lazy = true;
        runtimePkgs = with pkgs; [yaml-language-server];
        data = [];
      };

      json = {
        lazy = true;
        runtimePkgs = with pkgs; [vscode-json-languageserver];
        data = with pkgs.vimPlugins; [SchemaStore-nvim];
      };

      typescript = {
        lazy = true;
        runtimePkgs = with pkgs; [
          typescript
          typescript-language-server
          prettierd
          eslint
          eslint_d
        ];
        data = with pkgs.vimPlugins; [typescript-tools-nvim];
      };

      nulang = {
        lazy = true;
        runtimePkgs = with pkgs; [nu-lint];
        data = [];
      };

      cpp = {
        lazy = true;
        runtimePkgs = with pkgs; [clang-tools];
        data = [config.nvim-lib.neovimPlugins.clangd-extensions];
      };
    };
  };
}
