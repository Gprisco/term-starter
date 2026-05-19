# AGENTS.md

## What this repo is

Dotfiles/config starter: copies a Neovim config and `.zshrc` to the right locations.

## Workflow

**Edit here, deploy with the script — never edit `~/.config/nvim` directly.**

```bash
./install.sh          # deploy .config/nvim → ~/.config/nvim and .zshrc → ~/.zshrc
./syncNvimConfig.sh   # pull changes back from ~/.config/nvim into repo (before committing)
```

On Windows: `.\install.ps1` copies `.config/nvim` to `%LOCALAPPDATA%\nvim`.

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
1. Optionally call `vim.lsp.config('server_name', { ... })` in `lua/lsp.lua` to customize defaults.
2. Add `'server_name'` to the `vim.lsp.enable({ ... })` call at the bottom of `lua/lsp.lua`.

Servers must be installed on the system:
- TypeScript: `npm i -g typescript-language-server typescript`
- Lua: `brew/pacman/apt install lua-language-server`
- C#: download linux-x64 nuget from `https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.linux-x64/<version>/microsoft.codeanalysis.languageserver.linux-x64.<version>.nupkg`, extract `content/LanguageServer/linux-x64/` to `~/.roslyn/`, and `chmod +x ~/.roslyn/Microsoft.CodeAnalysis.LanguageServer`

TypeScript uses project-local `tsserver` when available, falls back to global.
C# is handled by `plugin/roslyn.lua` (roslyn_ls via nvim-lspconfig) — root detection looks for `*.sln`, `*.csproj`, or `.git`.

## Key conventions

- Leader is `<Space>`
- Adding a new plugin: create `plugin/<name>.lua`, call `vim.pack.add()` inside `require('lazyload').on_vim_enter(...)` (or eagerly for colorschemes/dashboards)
- `lua/*.lua` modules auto-reload on save (clears `package.loaded` and re-requires)
- `init.lua` auto-reloads via `source $MYVIMRC` on save
- neoscroll owns `<C-d>`/`<C-u>` — do not remap those in `keymaps.lua`
