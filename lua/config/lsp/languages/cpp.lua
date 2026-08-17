return {
  {
    "clangd",
    lsp = {
      root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
        "Makefile",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja",
        ".git"
      },
      filetypes = { "c", "cpp" },
      settings = {
        clangd = {
          capabilities = {
            offsetEncoding = { "utf-16" }
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm"
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true
          }
        }
      }
    }
  },
  {
    "clangd-extensions",
    ft = { "c", "cpp", "objc", "objcpp" },
    after = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = false
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = ""
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = ""
          }
        }
      })
    end
  }
}
