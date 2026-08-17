# evaluated at runtime by the nixd language server (see the `get_configs`
# function handed to lua via config.info.nixdExtras in module.nix).
#
# called as `import <this file> <system> <type> <path>` where <type> is one of
# "nixos" / "home-manager" / "darwin" and <path> is the flake to inspect
# (the lsp workspace root when nil). it collects the options of EVERY
# nixosConfigurations / homeConfigurations / darwinConfigurations entry,
# looking in both `outputs.*` and `outputs.legacyPackages.<system>.*`, and
# deep-merges them — so multi-host flakes get the union of their options and
# flakes without any configurations evaluate to {} instead of erroring.
system: type: path: let
  inherit (builtins) length head elemAt zipAttrsWith isAttrs attrValues concatLists foldl' getFlake;
  pipe = foldl' (x: f: f x);
  attrByPath = attrPath: default: set: let
    lenAttrPath = length attrPath;
    attrByPath' = n: s: (
      if n == lenAttrPath
      then s
      else
        (
          let
            attr = elemAt attrPath n;
          in
            if s ? ${attr}
            then attrByPath' (n + 1) s.${attr}
            else default
        )
    );
  in
    attrByPath' 0 set;

  # recursive merge that prefers the deeper (attrset) side on conflicts;
  # on leaf conflicts the later value (foldl' accumulator order below) wins.
  recMergePickDeeper = lhs: rhs: let
    pred = _path: lh: rh: !isAttrs lh || !isAttrs rh;
    pick = _path: l: r:
      if isAttrs l
      then l
      else r;
    f = attrPath:
      zipAttrsWith (
        n: values: let
          here = attrPath ++ [n];
        in
          if length values == 1
          then head values
          else if pred here (elemAt values 1) (head values)
          then pick here (elemAt values 1) (head values)
          else f here values
      );
  in
    f [] [rhs lhs];

  allTargets = {
    nixos = [
      ["outputs" "nixosConfigurations"]
      ["outputs" "legacyPackages" system "nixosConfigurations"]
    ];
    home-manager = [
      ["outputs" "homeConfigurations"]
      ["outputs" "legacyPackages" system "homeConfigurations"]
    ];
    darwin = [
      ["outputs" "darwinConfigurations"]
      ["outputs" "legacyPackages" system "darwinConfigurations"]
    ];
  };
  targetFlake = getFlake "path:${toString path}";
  getCfgs = atp: attrValues (attrByPath atp {} targetFlake);
in
  pipe (allTargets.${type} or []) [
    (map getCfgs)
    concatLists
    (map (v: v.options or {}))
    (foldl' recMergePickDeeper {})
  ]
