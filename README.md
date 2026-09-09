> [!NOTE]
> **Moved to [Codeberg](https://codeberg.org/angeldust/angeldust-nvimWrap)** — GitHub now serves as a mirror.

# angeldust-nvimWrap

[![cachix](https://img.shields.io/badge/cache-meflove.cachix.org-0096ff?logo=cachix)](https://meflove.cachix.org)
[![neovim](https://img.shields.io/badge/neovim-nightly-57a143?logo=neovim&logoColor=white)](https://github.com/neovim/neovim)
[![nixpkgs](https://img.shields.io/badge/nixpkgs-unstable-006899?logo=nixos&logoColor=white)](https://github.com/NixOS/nixpkgs)

> A fully reproducible Neovim distribution: plugins, LSPs, formatters, linters and
> treesitter grammars — all declared in Nix, lazy-loaded with [lze], and running on
> **Neovim nightly**.
>
> Built on [BirdeeHub/nix-wrapper-modules] (migrated from [nixCats] — see the
> [migration table](#coming-from-nixcats)).

## ✨ Highlights

- 🔁 **100 % reproducible** — plugins, LSPs, formatters, linters, treesitter grammars,
  even the `python3` / `node` / `perl` provider hosts come from the flake.
  No mason, no `:PlugInstall`, nothing is fetched at runtime.
- 🌙 **Neovim nightly is bundled**, including experiments with the new
  `vim._core.ui2` message UI: floating message window, animated LSP progress
  spinner, `cmdheight = 0` with [tiny-cmdline.nvim].
- ⚡ **Lazy loading** via [lze] + [lzextras] (pinned from source for freshness),
  with a custom `auto_enable` handler that silently disables lua specs whose
  plugin nix didn't install — so nix stays the single source of truth.
- 🧩 **`plugins-<name>` inputs** — any flake input prefixed with `plugins-` is
  built straight from its repo and exposed as `config.nvim-lib.neovimPlugins.<name>`
  (that's how `flash.nvim`, `bafa.nvim`, `tiny-inline-diagnostic.nvim`, … stay fresh).
- 🗂️ **Per-language specs** — every language owns its plugins, its CLI tools _and_
  its info values (`mainInfo`); `config.specs.<lang>.enable = false` removes all
  three from the wrapper — the plugins, the `PATH` entries and the `nixInfo`
  values.
- ✍️ **[blink.cmp]** completion — LuaSnip snippets, colorful-menu rendering,
  cmdline completion.
- 🦀 **Deep Rust setup** — rust-analyzer (nightly), bacon-ls diagnostics as you
  type, RustOwl lifetime/ownership hints, crates.nvim in `Cargo.toml`.
- ❄️ **Nix-native editing** — nixd + nil, alejandra / statix / deadnix, and nixd
  autocompleting the _edited flake's_ NixOS / Home-Manager options (auto-detected,
  no hardcoded hostnames).
- 🎮 The statusline awards XP for editing ([triforce.nvim]). Yes, really.

## 📦 Installation

Requirements: Nix with flakes, `x86_64-linux`, a truecolor terminal.
Everything else — including Neovim itself — is in the flake.

```bash
# try it without installing
nix run github:meflove/angeldust-nvimWrap

# install into your profile
nix profile install github:meflove/angeldust-nvimWrap

# build locally
nix build github:meflove/angeldust-nvimWrap
```

> The first build compiles a lot (all treesitter grammars, a Rust toolchain,
> rust-analyzer nightly, …). Point nix at the binary cache to skip most of it —
> the public key is listed on <https://meflove.cachix.org>:
>
> ```nix
> substituters = [ "https://meflove.cachix.org" ];
> ```

### NixOS / Home Manager

```nix
inputs.angeldust-nvimWrap.url = "github:meflove/angeldust-nvimWrap";
```

As an overlay — self-contained, replaces `pkgs.neovim` with the wrapped editor:

```nix
nixpkgs.overlays = [ inputs.angeldust-nvimWrap.overlays.default ];
environment.systemPackages = [ pkgs.neovim ];
```

As a module — importable and overridable from the host config:

```nix
imports = [ inputs.angeldust-nvimWrap.nixosModules.neovim ]; # or .homeModules.neovim

wrappers.neovim = {
  enable = true;
  # override anything from nix/module.nix:
  settings.colorscheme = "catppuccin-mocha";
};

home.sessionVariables.EDITOR = lib.getExe config.wrappers.neovim.wrapper;
```

> ⚠️ The `packages` and `overlays` outputs are self-contained. The
> `nixosModules` / `homeModules` path evaluates `nix/module.nix` against **your**
> nixpkgs, which then needs the tooling overlays from [`flake.nix`](flake.nix)
> (`fenix`, `bacon-ls`, `nu-lint`, `emmylua-ls`, `statix`, `rustowl`) applied.
> See the [nix-wrapper-modules getting-started guide] for details.

## 🗂️ Project structure

```text
.
├── flake.nix              # inputs, tooling overlays, flake outputs
├── init.lua               # bootstrap: leader keys, vim.loader, require("config")
├── nix/
│   ├── module.nix         # composition root: imports, settings, package, hosts
│   ├── nvim-lib.nix       # nvim-lib helpers + spec fields (runtimePkgs, mainInfo)
│   ├── general.nix        # lze engine, colorscheme and the bulk of the editor
│   ├── langs.nix          # per-language specs, each with its own mainInfo
│   ├── nixd.nix           # runtime-evaluated nixd expr: the edited flake's options
│   └── treefmt.nix        # `nix fmt` — alejandra, statix, deadnix, luafmt, prettier
├── lua/config/
│   ├── init.lua           # nixInfo bridge + lze handler registration
│   ├── options.lua        # vim.opt / vim.o
│   ├── keymaps.lua        # global keymaps
│   ├── autocmds.lua       # cursor restore, auto-mkdir, LSP cleanup, …
│   ├── colorscheme.lua    # theme setup (rose-pine / catppuccin / tokyonight)
│   ├── ui2.lua            # vim._core.ui2 message routing (nightly)
│   ├── format.lua         # conform.nvim
│   ├── nvim-lint.lua      # nvim-lint
│   ├── lsp/               # core + on_attach + per-language specs
│   │   └── languages/     # bash, cpp, json, lua, md, nix, nulang, python, rust, ts, typst, yaml
│   ├── plugins/           # lze specs by concern: ui, editor, git, completion, …
│   ├── snippets/          # LuaSnip snippets (lua, nix, python)
│   └── utils/             # lze handlers: auto_enable, which-key, lsp ft fallback
├── after/queries/         # custom treesitter query injections
├── devenv.nix             # dev shell + git hooks (prek)
└── .github/workflows/     # cachix push, lock updates, codeberg/tangled mirror
```

How the two halves talk to each other:

1. The `nix/` modules decide what exists — each spec carries its plugins
   (`data`), its CLI tools (`runtimePkgs`) and its `mainInfo` values;
   `nvim-lib.nix` collects the latter two into the wrapper's `PATH` and the
   `info` plugin.
2. `init.lua` exposes them as the `nixInfo` global (the replacement for the
   old `nixCats` global) and registers lze handlers.
3. The `auto_enable` handler compares each lua spec against the nix-installed
   plugin list and disables the ones nix didn't provide.

## 🧩 Customization

### Colorscheme

```nix
# nix/module.nix
settings.colorscheme = "rose-pine-moon";
```

Available: `rose-pine`, `rose-pine-moon`, `catppuccin-macchiato`,
`catppuccin-mocha`, `tokyonight-storm`.

### Enable / disable a language

```nix
# nix/langs.nix — the lua side follows automatically via auto_enable
config.specs.rust.enable = false;
# ↑ drops the rust plugins AND rust-analyzer / bacon / fenix from PATH
```

### Add a plugin straight from its repo

```nix
# flake.nix — the plugins- prefix is all it takes
plugins-myplugin.url = "github:author/myplugin.nvim";
plugins-myplugin.flake = false;

# nix/general.nix
general.data = [ config.nvim-lib.neovimPlugins.myplugin ];
```

### Coming from nixCats

<details>
<summary>Migration mapping (click to expand)</summary>

| nixCats                               | here                                                |
| ------------------------------------- | --------------------------------------------------- |
| `lspsAndRuntimeDeps.<cat>`            | `config.specs.<cat>.runtimePkgs`                    |
| `startupPlugins.<cat>`                | `config.specs.<cat>.data` (`lazy = false`)          |
| `optionalPlugins.<cat>`               | `config.specs.<cat>.data` (`lazy = true`)           |
| `categories.<cat> = true`             | `config.specs.<cat>.enable` (defaults to true)      |
| `nixCats.extra.<x>`                   | `config.specs.<cat>.mainInfo.<x>` → `config.info`   |
| `packageDefinitions` / `nixCats(...)` | the `nixInfo` global + `wlib.wrapperModules.neovim` |
| `neovim-unwrapped` override           | `config.package`                                    |

</details>

## 🌐 Language support

| Language      | LSP                                        | Formatting                 | Linting            | Extra plugins                           |
| ------------- | ------------------------------------------ | -------------------------- | ------------------ | --------------------------------------- |
| Lua           | emmylua_ls                                 | luafmt (emmylua_formatter) | —                  | lazydev.nvim                            |
| Nix           | nixd, nil                                  | alejandra                  | statix             | —                                       |
| Python        | ty, ruff                                   | ruff (format + imports)    | —                  | —                                       |
| Rust          | rust-analyzer (nightly), bacon-ls, RustOwl | rustfmt (LSP fallback)     | clippy (via bacon) | rustaceanvim, crates.nvim, rustowl-nvim |
| TOML          | taplo                                      | —                          | —                  | crates.nvim                             |
| TypeScript/JS | typescript-language-server                 | prettierd                  | eslint_d           | typescript-tools.nvim                   |
| JSON          | vscode-json-languageserver                 | fixjson, json_repair       | jsonlint           | SchemaStore.nvim                        |
| YAML          | yaml-language-server                       | yamlfmt, yamlfix           | yamllint           | —                                       |
| Shell         | bash-language-server                       | shfmt                      | shellcheck         | —                                       |
| C / C++       | clangd                                     | clang-format               | clangtidy          | clangd_extensions.nvim                  |
| Markdown      | marksman                                   | prettierd                  | —                  | markview.nvim, markdown-preview.nvim    |
| Typst         | tinymist                                   | typstyle                   | —                  | typst-preview.nvim                      |
| Nushell       | nu-lint                                    | —                          | —                  | —                                       |

Also on the wrapper's `PATH` for everything else: `ripgrep`, `fd`,
`universal-ctags`, `tree-sitter`, `sqlite`, `unzip`, `ghostscript`, `tectonic`,
`mermaid-cli`.

## ⌨️ Keybindings

`<leader>` is `<Space>`. Press `<leader>?` for buffer-local maps — and see the
which-key groups: `c` code, `d` diff, `g` git, `m` markdown, `r` rename,
`s` search, `t` trouble, `w` workspace.

### General

| Key                       | Action                                |
| ------------------------- | ------------------------------------- |
| `<C-s>`                   | save (any mode)                       |
| `<leader><leader>`        | Neural Open — fast file switcher      |
| `<leader>e` / `<leader>E` | toggle / focus the Snacks explorer    |
| `<leader>/`               | live grep                             |
| `<leader>ss`              | LSP symbols                           |
| `<leader>su`              | undo history                          |
| `<leader>sr`              | search & replace (grug-far.nvim)      |
| `<leader>.`               | scratch buffer                        |
| `gb`                      | buffer switcher (bafa.nvim)           |
| `s` / `S`                 | flash jump / treesitter select        |
| `<C-space>`               | treesitter incremental selection      |
| `am` `im` `ac` `ic` `as`  | textobjects: function / class / scope |
| `<leader>y` `Y` `p` `P`   | clipboard yank / paste helpers        |

### LSP

| Key                           | Action                                 |
| ----------------------------- | -------------------------------------- |
| `gd` / `gD`                   | definition / declaration               |
| `K`                           | hover (hover.nvim previews)            |
| `<C-k>`                       | signature help                         |
| `<leader>rn`                  | rename                                 |
| `<leader>ca`                  | code action                            |
| `<leader>D`                   | type definition                        |
| `<leader>wa` `wr` `wl`        | workspace folders: add / remove / list |
| `<leader>txx` / `<leader>txX` | Trouble: project / buffer diagnostics  |

### Git

| Key                           | Action                            |
| ----------------------------- | --------------------------------- |
| `]c` / `[c`                   | next / previous hunk              |
| `<leader>gs` / `<leader>gr`   | stage / reset hunk                |
| `<leader>gS` / `<leader>gR`   | stage / reset buffer              |
| `<leader>gu`                  | undo stage hunk                   |
| `<leader>gp`                  | preview hunk                      |
| `<leader>gb`                  | blame line                        |
| `<leader>gd` / `<leader>gD`   | diff against index / last commit  |
| `<leader>gtb` / `<leader>gtd` | toggle line blame / deleted lines |
| `ih`                          | hunk textobject                   |
| `<leader>dm` `dl` `da`        | deltaview menu / view / delta     |

### Rust & Markdown

| Key                           | Action                                    |
| ----------------------------- | ----------------------------------------- |
| `<leader>ca`                  | rust code actions (grouped, rustaceanvim) |
| `<leader>cro` `cre` `crd`     | RustOwl: toggle / enable / disable        |
| `<leader>cv` `cf` `cU` `cA` … | crates.nvim in `Cargo.toml`               |
| `<leader>mp` `ms` `mt`        | markdown preview: start / stop / toggle   |

## 🛠️ Development

```bash
nix develop          # or: direnv allow — devenv shell with prek git hooks
nix fmt              # treefmt: alejandra, statix, deadnix, luafmt, prettier
nix flake check      # formatting check
nix build .#neovim   # local build
```

The dev shell runs [prek] hooks on commit: alejandra, statix, luafmt, lua-ls,
end-of-file / trailing-whitespace fixes, private-key detection.

## 🔄 CI

- **push-to-cachix** — every push to `main` builds the wrapper and pushes it to
  [meflove.cachix.org](https://meflove.cachix.org).
- **update-flake-lock** — Mon & Thu: bumps `flake.lock` and `devenv.lock`.
- **mirror** — pushes `main` to [Codeberg] and Tangled.

## 🙏 Acknowledgements

- [BirdeeHub/nix-wrapper-modules] — the build system, and the template this
  config started from.
- [BirdeeHub/birdeevim] — the reference for the `nix/` module layout
  (`nvim-lib.nix` / `general.nix` / `langs.nix` and the `mainInfo` spec field).
- [lze] / [lzextras] — lazy loading that plays well with nix.
- Everyone who wrote the plugins listed in [`nix/general.nix`](nix/general.nix)
  and [`nix/langs.nix`](nix/langs.nix).

[lze]: https://github.com/BirdeeHub/lze
[lzextras]: https://github.com/BirdeeHub/lzextras
[BirdeeHub/nix-wrapper-modules]: https://github.com/BirdeeHub/nix-wrapper-modules
[BirdeeHub/birdeevim]: https://github.com/BirdeeHub/birdeevim
[nix-wrapper-modules getting-started guide]: https://birdeehub.github.io/nix-wrapper-modules/md/getting-started.html
[nixcats]: https://github.com/BirdeeHub/nixCats-nvim
[tiny-cmdline.nvim]: https://github.com/rachartier/tiny-cmdline.nvim
[blink.cmp]: https://github.com/Saghen/blink.cmp
[triforce.nvim]: https://github.com/gisketch/triforce.nvim
[prek]: https://github.com/j178/prek
[jujutsu]: https://github.com/martinvonz/jj
[codeberg]: https://codeberg.org/angeldust/angeldust-nvimWrap
