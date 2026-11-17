{
  inputs,
  self,
}: let
  # Overlays applied to the nixpkgs used to BUILD neovim, so that the extra
  # tools (fenix, bacon, statix, nu-lint, ...) are visible as `pkgs.<name>`
  # inside module.nix's `runtimePkgs`.
  overlays = [
    inputs.fenix.overlays.default
    inputs.rustowl.overlays.default
    (import "${inputs.statix}/overlay.nix")
    (
      _final: prev: let
        inherit (prev.stdenv.hostPlatform) system;

        mkEmmylua = x:
          prev.callPackage
          ({
            cmake,
            openssl,
            pkg-config,
            rustPlatform,
          }: let
            src = inputs.emmylua-ls;
            cargoToml = fromTOML (builtins.readFile "${src}/crates/${x}/Cargo.toml");
          in
            rustPlatform.buildRustPackage {
              inherit src;

              pname = cargoToml.package.name;
              version = cargoToml.package.version;

              strictDeps = true;

              cargoLock.lockFile = src + /Cargo.lock;

              nativeBuildInputs = [pkg-config cmake];
              buildInputs = [openssl];

              env.OPENSSL_NO_VENDOR = 1;

              buildAndTestSubdir = "crates/${x}";
              doCheck = false;
            }) {};
      in {
        # lua
        emmylua_ls = mkEmmylua "emmylua_ls";
        emmylua_check = mkEmmylua "emmylua_check";
        emmylua_formatter = mkEmmylua "emmylua_formatter";

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

        # kdl
        kdl-lsp = self.legacyPackages.${system}.deps.kdl-lsp;

        # nixpkgs-master channel (kept for ad-hoc use)
        master = import inputs.nixpkgs-master (branchConfig system);
      }
    )
  ];

  branchConfig = system: {
    inherit overlays;
    config = {
      allowBroken = true;
      allowInsecure = true;
      allowUnfree = true;
    };
    inherit system;
  };
in {
  # Build a pkgs set with our overlays + allowUnfree for a given system.
  mkPkgs = system: import inputs.nixpkgs (branchConfig system);
}
