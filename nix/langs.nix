# language / tool specs. each carries its own runtimePkgs
# (LSPs/formatters/linters) and spec-specific mainInfo so disabling the spec
# (`config.specs.<lang>.enable = false;`) removes the plugins, the tools from
# PATH and the info values. auto_enable in lua then silently skips the lze specs.
{
  config,
  lib,
  pkgs,
  ...
}: {
  config.specs = {
    nix = {
      lazy = true;
      mainInfo.nixdExtras = {
        nixpkgs = ''import ${pkgs.path} {}'';
        get_configs =
          lib.generators.mkLuaInline
          # lua
          ''function(type, path) return [[import ${./nixd.nix} "${pkgs.stdenv.hostPlatform.system}" "]] .. type .. [[" ]] .. (path or "./.") end'';
      };
      runtimePkgs = with pkgs; [
        nixd
        nil
        alejandra
        statix
      ];
      data = [];
    };

    lua = {
      lazy = true;
      # luafmt from conform doesn't work (read via nixInfo in
      # lua/config/format.lua)
      mainInfo.emmylua_formatter_path = lib.getExe' pkgs.emmylua_formatter "luafmt";
      runtimePkgs = with pkgs; [
        emmylua_ls
        emmylua_formatter
      ];
      data = with pkgs.vimPlugins; [lazydev-nvim];
    };

    python = {
      lazy = true;
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
      runtimePkgs = with pkgs; [
        marksman
        prettierd
      ];
      data = with pkgs.vimPlugins; [
        markdown-preview-nvim
        markview-nvim
      ];
    };

    typst = {
      lazy = true;
      runtimePkgs = with pkgs; [
        typst
        typstyle
        tinymist
        curl
      ];
      data = with pkgs.vimPlugins; [
        typst-preview-nvim
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
      runtimePkgs = with pkgs; [
        yaml-language-server
        yamllint
        yamlfmt
        yamlfix
      ];
      data = with pkgs.vimPlugins; [SchemaStore-nvim];
    };

    json = {
      lazy = true;
      runtimePkgs = with pkgs; [
        vscode-json-languageserver
        python3Packages.demjson3
        fixjson
        python3Packages.json-repair
      ];
      data = with pkgs.vimPlugins; [SchemaStore-nvim];
    };

    typescript = {
      lazy = true;
      runtimePkgs = with pkgs; [
        typescript
        typescript-language-server
        eslint
        prettierd
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
}
