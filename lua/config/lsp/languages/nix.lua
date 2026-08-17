-- lua function from specs.nix.mainInfo.nixdExtras (nix/langs.nix): builds the nixd
-- `options` exprs so that nixd evaluates nixd.nix at runtime and merges the
-- options of ALL nixosConfigurations / homeConfigurations entries of the flake
-- being edited. nil when the nix side didn't provide it.
local get_nixd_opts = nixInfo(nil, "info", "nixdExtras", "get_configs")

return {
  {
    "nil_ls",
    lsp = {
      root_markers = { "flake.nix", ".git" },
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
          -- values handed over from nix via specs.nix.mainInfo.nixdExtras
          nixpkgs = {
            expr = nixInfo(nil, "info", "nixdExtras", "nixpkgs") or [[import <nixpkgs> {}]]
          },
          options = {
            -- flake-path (nil) falls back to the lsp workspace root
            nixos = {
              expr = get_nixd_opts and get_nixd_opts("nixos", nixInfo(nil, "info", "nixdExtras", "flake-path"))
            },
            ["home-manager"] = {
              expr = get_nixd_opts and get_nixd_opts("home-manager", nixInfo(nil, "info", "nixdExtras", "flake-path"))
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
