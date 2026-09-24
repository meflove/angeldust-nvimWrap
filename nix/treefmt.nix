{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.pedantix.treefmtModules.default
  ];
  settings = {
    global = {
      on-unmatched = "warn";
      excludes = [
        ".gitignore"
        ".envrc"
      ];
    };
    formatter = {
      emmylua = let
        luafmt = lib.getExe' pkgs.emmylua_formatter "luafmt";
      in {
        command = lib.getExe pkgs.bash;
        includes = ["*.lua"];
        options = [
          "-euc"
          ''
            for file in "$@"; do
              ${luafmt} --write "$file"
            done
          ''
          "--"
        ];
      };
    };
  };
  programs = {
    # nix
    alejandra = {
      enable = true;
      priority = 1;
      includes = [
        "*.nix"
      ];
    };

    pedantix = {
      enable = true;
      priority = 2;
      package = pkgs.pedantix;
      includes = [
        "*.nix"
      ];
      settings = {
        preset = "nixos-module";
        formatter = "alejandra";

        args = {
          sort = true;
        };
        attrs = {
          sort = false;
        };
        inherits = {
          sort = false;
        };
        lets = {
          sort = false;
        };
      };
    };

    statix = {
      enable = true;
      priority = 3;
      includes = [
        "*.nix"
      ];
    };

    deadnix = {
      enable = true;
      priority = 4;
      includes = [
        "*.nix"
      ];

      no-underscore = true;
    };

    # md
    prettier = {
      enable = true;
      includes = [
        "*.md"
      ];
    };

    # json
    jsonfmt = {
      enable = true;
      includes = [
        "*.json"
        "*.jsonc"
      ];
    };

    # toml
    taplo = {
      enable = true;
      includes = [
        "*.toml"
      ];
    };

    # yaml
    yamlfmt = {
      enable = true;
      includes = [
        "*.yaml"
        "*.yml"
      ];

      settings = {
        formatter = {
          include_document_start = true;
        };
      };
    };
  };
}
