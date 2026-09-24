{
  lib,
  pkgs,
  inputs,
  ...
}: {
  name = "nixland";

  cachix.push = "meflove";

  languages = {
    nix.enable = true;
    lua = {
      enable = true;
      package = pkgs.luajit;
    };
  };

  packages = with pkgs; [
    glow # for md files
  ];

  enterShell =
    # bash
    ''
      echo -e "\n\e[33m⚙ Welcome\e[0m \e[37mto the\e[0m \e[36m nvimWrap\e[0m \e[35mconfiguration development\e[0m \e[32mshell!\e[0m\n"

      ${lib.getExe pkgs.jujutsu} status --no-pager
    '';

  git-hooks = {
    package = pkgs.prek;

    hooks = {
      # Basic hooks
      end-of-file-fixer.enable = true;
      trim-trailing-whitespace.enable = true;
      detect-private-keys.enable = true;

      treefmt = {
        enable = true;
        package = inputs.self-repo.formatter.${pkgs.stdenv.hostPlatform.system};
      };
    };
  };
}
