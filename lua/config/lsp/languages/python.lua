-- root markers shared by both python servers (ruff, ty)
local python_root_markers = {
  "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "ruff.toml", ".ruff.toml",
  "pyrightconfig.json", ".git"
}

return {
  {
    "ruff",
    lsp = {
      root_markers = python_root_markers,
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
    lsp = {
      root_markers = python_root_markers,
      filetypes = { "python" },
      settings = {
        ty = {
          diagnosticMode = "workspace"
        }
      }
    }
  }
}
