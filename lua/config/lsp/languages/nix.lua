return {
  {
    "nil_ls",
    root_markers = { "flake.nix", ".git" },
    lsp = {
      filetypes = { "nix" },
      settings = {
        nil_ls = {
          nix = {
            flake = {
              autoArchive = true,
              autoEvalInputs = true
            }
          }
        }
      }
    }
  },
  {
    "nixd",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          -- values handed over from nix via config.info.nixdExtras in module.nix
          nixpkgs = {
            expr = nixInfo(nil, "info", "nixdExtras", "nixpkgs") or [[import <nixpkgs> {}]]
          },
          options = {
            nixos = {
              expr = nixInfo(nil, "info", "nixdExtras", "nixos_options")
            },
            ["home-manager"] = {
              expr = nixInfo(nil, "info", "nixdExtras", "home_manager_options")
            }
          },
          formatting = {
            command = { "alejandra" }
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with"
            }
          }
        }
      }
    }
  }
}
