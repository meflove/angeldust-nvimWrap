# core specs: the lazy-loading engine, the colorscheme and the bulk of the
# editor.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # a list of theme names (first one is used by default)
  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "rose-pine";
  };

  config.specs = {
    # ------------------------------------------------- lazy-loading engine
    # lze + lzextras, fetched from source (plugins-lze / plugins-lzextras inputs).
    # must be startup (lazy = false) so the engine is available before anything loads.
    lze = with config.nvim-lib.neovimPlugins; [
      lze
      lzextras
      # {
      #   data = config.nvim-lib.neovimPlugins.lzextras;
      #   name = "lzextras";
      # }
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

      # sqlite path for the snacks picker db (read via nixInfo in
      # lua/config/plugins/ui.lua)
      mainInfo.sqlite_lib = "${pkgs.sqlite.out}/lib/libsqlite3.so";

      runtimePkgs = with pkgs; [
        (writeShellScriptBin "ctags-wrapped" ''
          exec ${lib.getExe universal-ctags} \
            --exclude=.git \
            --exclude=.jj \
            --exclude=.direnv \
            --exclude=target \
            --exclude=result \
            --exclude=node_modules \
            --exclude=vendor \
            --exclude=build \
            --exclude=dist \
            --exclude=.venv \
            --exclude=__pycache__ \
            --exclude=*.min.js\
            --links=no \
            "$@"
        '')
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
        {
          data = which-key-nvim;
          lazy = false;
        }
        # --- LSP core ---
        nvim-lspconfig

        # --- format and lint ---
        conform-nvim
        nvim-lint

        # --- completion ---
        luasnip
        cmp-cmdline
        blink-compat
        colorful-menu-nvim
        blink-cmp

        # --- editor ---
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
        rainbow-delimiters-nvim
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
        nvim-autopairs
      ];
    };
  };
}
