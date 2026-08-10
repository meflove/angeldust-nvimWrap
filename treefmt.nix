{
  lib,
  pkgs,
  ...
}: {
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
              ${luafmt} --write $file
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

    statix = {
      enable = true;
      priority = 1;
      includes = [
        "*.nix"
      ];
    };

    deadnix = {
      enable = true;
      priority = 1;
      includes = [
        "*.nix"
      ];
    };

    #lua
    # stylua = {
    #   enable = true;
    #   priority = 1;
    #   includes = [
    #     "*.lua"
    #   ];
    # };
    # emmylua = {
    #   enable = true;
    #   priority = 1;
    #   includes = [
    #     "*.lua"
    #   ];
    # };

    # md
    prettier = {
      enable = true;
      priority = 2;
      includes = [
        "*.md"
      ];
    };
  };
}
