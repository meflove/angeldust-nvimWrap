{
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  src = fetchFromGitHub {
    owner = "kdl-org";
    repo = "kdl-rs";
    rev = "443af89348ed63c2392f95eb1985211e77983de3";
    hash = "sha256-A/OK2/t30y7Y9DK0kE3OIJ+bcl9WrMaKkBOC/+bvXnA=";
  };

  cargoToml = lib.importTOML "${src.outPath}/Cargo.toml";
  version = "${cargoToml.package.version}-${lib.substring 0 7 src.rev}";
in
  rustPlatform.buildRustPackage (_finalAttrs: {
    inherit src version;
    pname = "kdl-lsp";

    cargoHash = "sha256-lAmfaH3SpX0Al2VuT+V/0K5+KpwV0uIKZV0idoUy08w=";

    buildAndTestSubdir = "tools/kdl-lsp";

    meta = with lib; {
      description = "LSP Server for the KDL Document Language";
      homepage = "https://kdl.dev";
      changelog = "https://github.com/kdl-org/kdl-rs/blob/v${cargoToml.package.version}/tools/kdl-lsp/CHANGELOG.md";
      license = licenses.asl20;
      mainProgram = "kdl-lsp";
    };
  })
