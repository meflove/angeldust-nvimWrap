# nvim-lib: plugin-building helpers, the spec fields shared by every spec
# (runtimePkgs, mainInfo) and the code collecting them into
# config.runtimePkgs / config.info. mirrors the nvim-lib.nix of
# BirdeeHub/birdeevim.
{
  config,
  wlib,
  lib,
  options,
  inputs,
  ...
}: {
  # makes inputs named `plugins-<name>` available as
  # `config.nvim-lib.neovimPlugins.<name_without_prefix>` (auto-built from source).
  options.nvim-lib = {
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

    neovimPlugins = lib.mkOption {
      readOnly = true;
      type = lib.types.attrsOf wlib.types.stringable;
      default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
    };
  };

  # -------------------------------------------------- specMods: spec fields
  # runtimePkgs (from the tips-and-tricks section) puts per-spec tools on PATH;
  # mainInfo (from birdeevim) merges spec-specific attrs into the main info
  # plugin, read from lua via `nixInfo(<default>, "info", ...)`.
  config = {
    specMods = _: {
      options = {
        runtimePkgs =
          options.runtimePkgs
          // {
            description = ''
              Packages to put on the wrapped neovim's PATH for this spec.
              Skipped when the spec is disabled.
            '';
          };
        mainInfo = lib.mkOption {
          type = wlib.types.attrsRecursive;
          default = {};
          description = ''
            Attrs merged into the main info plugin for this spec.
            Skipped when the spec is disabled.
          '';
        };
      };
    };

    # ------------------------------------------------------------ collections
    # collect the spec fields — skipping disabled specs so disabling a category
    # is clean.
    runtimePkgs =
      config.specCollect
      (acc: v: acc ++ lib.optionals (v.enable or true) (v.runtimePkgs or []))
      [];

    info = lib.mkMerge (
      config.specCollect
      (
        acc: v:
          acc
          ++ lib.optionals ((v.enable or true) && (v.mainInfo or {}) != {})
          [v.mainInfo]
      )
      []
    );
  };
}
