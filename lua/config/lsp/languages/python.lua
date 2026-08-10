return {
  {
    "ruff",
    root_markers = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "ruff.toml",
      ".ruff.toml",
      "pyrightconfig.json",
      ".git"
    },
    lsp = {
      filetypes = { "python" },
      settings = {
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "info",
              configurationPreference = "filesystemFirst",
              lint = {
                preview = true
              },
              format = {
                preview = true
              },
              configuration = {
                format = {
                  ["quote-style"] = "single"
                }
              }
            }
          }
        }
      }
    }
  },
  {
    "ty",
    root_markers = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "ruff.toml",
      ".ruff.toml",
      "pyrightconfig.json",
      ".git"
    },
    lsp = {
      filetypes = { "python" },
      settings = {
        ty = {
          diagnosticMode = "workspace"
        }
      }
    }
  }
}
