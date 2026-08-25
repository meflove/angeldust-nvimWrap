{
  lib,
  rustPlatform,
  fetchFromGitHub,
}: let
  src = fetchFromGitHub {
    owner = "kdl-org";
    repo = "kdl-rs";
    rev = "14a44c0310b68e00c68857c167174ed4c0cbcfb5";
    hash = "sha256-uXWltmF9V4xGLf24lNUBwsGnjVzVr+JN0vs4PSz84XY=";
  };

  cargoToml = lib.importTOML "${src.outPath}/Cargo.toml";
  version = "${cargoToml.package.version}-${lib.substring 0 7 src.rev}";
in
  rustPlatform.buildRustPackage (finalAttrs: {
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
