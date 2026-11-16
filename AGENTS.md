# AGENTS.md

## What this repo is

Dotfiles/config starter: installs a mise-managed toolchain and copies a Neovim
config and `.zshrc` to the right locations.

## Workflow

**Edit here, deploy with the script — never edit `~/.config/nvim` directly.**

```bash
./install.sh          # deploy .config/nvim → ~/.config/nvim, link mise.toml, install tools
./install.sh --zshrc  # ...and also overwrite ~/.zshrc with this repo's (backs up first)
./syncNvimConfig.sh   # pull changes back from ~/.config/nvim into repo (before committing)
```

`--zshrc` is opt-in: a machine may already have a hand-written `~/.zshrc` that
this template would replace. `install.sh` also `rm -rf`s the target `nvim` dir
first, because `cp -r` into an existing directory would nest as `nvim/nvim`.

On Windows: `.\install.ps1` copies `.config/nvim` to `%LOCALAPPDATA%\nvim`. There
is no mise integration on Windows — language servers must be installed by hand.

## Toolchain (mise)

`mise.toml` is the single source of truth for tool versions and is symlinked to
`~/.config/mise/config.toml`; `mise.lock` is symlinked alongside it, so mise
writes lock updates straight back into the repo.

- Versions are **exact pins**. Bump with `mise lock --bump <tool>`, then commit both files.
- `mise.toml` declares tool options (`{ version = ..., prerelease = true }`), so it is not a
  "safe" config: `install.sh` runs `mise trust` before installing.
- The shell activates mise in **shims mode** (`.zshrc`: `mise activate zsh --shims`).
  Tools resolve for child processes that never run a mise prompt (nvim spawning
  language servers, fzf previews, git hooks).
- Consequence of shims mode: mise `[env]` vars reach mise-managed processes only,
  so `JAVA_HOME`/`DOTNET_ROOT` are **not** exported into the interactive shell.
  See `java.md` before adding java.
- mise itself is a prerequisite; install it before running `./install.sh`.
- `java` is intentionally absent from `mise.toml` — see `java.md`.

## Neovim config structure

```
.config/nvim/
├── init.lua                  — options, leader, keymaps/lsp requires, auto-reload autocmds
├── nvim-pack-lock.json       — vim.pack lockfile, commit this
├── plugin/                   — self-contained plugin files (sourced automatically at step 11)
│   ├── catppuccin.lua        — colorscheme (eager: vim.pack.add + setup directly)
│   ├── mini-pick.lua
│   ├── neoscroll.lua
│   ├── nvim-tree.lua
│   └── which-key.lua
└── lua/
    ├── keymaps.lua
    ├── lazyload.lua          — VimEnter queue helper
    └── lsp.lua
```

## Package manager

Uses **`vim.pack`** (Neovim 0.12+ built-in). No lazy.nvim or other external manager.

- Plugins install to `~/.local/share/nvim/site/pack/core/opt/`
- Each `plugin/<name>.lua` file owns its own `vim.pack.add()` call and setup
- Most plugins wrap setup in `require('lazyload').on_vim_enter(...)` for deferred startup
- Colorscheme (catppuccin) is the exception — it loads eagerly so the theme is set before VimEnter
- On first launch, Neovim prompts to confirm installation
- To update plugins: `:lua vim.pack.update()` inside Neovim

## LSP

Config via `lua/lsp.lua` using `vim.lsp.config` / `vim.lsp.enable` (Nvim 0.11+ API). No mason.nvim.

**nvim-lspconfig** (`plugin/nvim-lspconfig.lua`) is installed via `vim.pack` as a config registry — it provides default server configs (filetypes, root markers, cmd) into the runtimepath. `require('lspconfig')` is **not** used; it is deprecated.

To add a new server:
1. Declare the server binary in `mise.toml` and run `./install.sh`.
2. Optionally call `vim.lsp.config('server_name', { ... })` in `lua/lsp.lua` to customize defaults.
3. Add `'server_name'` to the `vim.lsp.enable({ ... })` call at the bottom of `lua/lsp.lua`.

Server binaries come from mise — do not document manual install steps:
- TypeScript: `npm:typescript-language-server` (needs `node`, also declared) plus
  `npm:typescript` — the server bundles no tsserver; `lua/lsp.lua` points it at
  the mise copy via `tsserver.fallbackPath` (a workspace's own `typescript` still
  wins). Pin typescript `< 7` until ts_ls supports TS 7.
- Lua: `lua-language-server`
- C#: `dotnet:roslyn-language-server` — a dotnet global tool, not a hand-extracted nuget

`lua/lsp.lua` sets **no `cmd`** for any of the three servers: nvim-lspconfig's
defaults resolve `roslyn-language-server` and `lua-language-server` from `PATH`,
and for `ts_ls` prefer a project-local `node_modules/.bin/typescript-language-server`
(resolved from `root_dir`) before falling back to the mise shim. The only
`ts_ls` override is `init_options.tsserver.fallbackPath` (see above).

Roslyn's root detection looks for `*.sln`, `*.csproj`, or `.git`. Bump the server
with `mise lock --bump dotnet:roslyn-language-server`.

## Key conventions

- Leader is `<Space>`
- Adding a new plugin: create `plugin/<name>.lua`, call `vim.pack.add()` inside `require('lazyload').on_vim_enter(...)` (or eagerly for colorschemes/dashboards)
- `lua/*.lua` modules auto-reload on save (clears `package.loaded` and re-requires)
- `init.lua` auto-reloads via `source $MYVIMRC` on save
- neoscroll owns `<C-d>`/`<C-u>` — do not remap those in `keymaps.lua`
