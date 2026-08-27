{
  lib,
  rustPlatform,
  fetchFromGitHub,
}: let
  src = fetchFromGitHub {
    owner = "kdl-org";
    repo = "kdl-rs";
    rev = "8b01f4ef83eea6ab399118117a7c02d7d597c4f2";
    hash = "sha256-O5x1k/c4RxzChkM5Fc37q1Al3Rxq5YvTMCYILFz9uSY=";
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
