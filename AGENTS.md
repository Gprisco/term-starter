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
├── init.lua                  — options, leader, module loader, auto-reload autocmds
├── nvim-pack-lock.json       — vim.pack lockfile, commit this
└── lua/
    ├── keymaps.lua
    ├── lsp.lua
    └── plugins/
        ├── init.lua          — vim.pack.add() + require each plugin
        ├── catppuccin.lua
        ├── mini-pick.lua
        ├── neoscroll.lua
        └── which-key.lua
```

## Package manager

Uses **`vim.pack`** (Neovim 0.12+ built-in). No lazy.nvim or other external manager.

- Plugins install to `~/.local/share/nvim/site/pack/core/opt/`
- On first launch, Neovim prompts to confirm installation
- After install, if plugin dirs appear empty (only `.git/`), run: `git checkout HEAD` inside each plugin dir — this is a known first-run quirk
- To update plugins: `:lua vim.pack.update()` inside Neovim

## LSP

Manual config via `FileType` autocmds in `lua/lsp.lua`. No mason.nvim.

Servers must be installed on the system:
- TypeScript: `npm i -g typescript-language-server typescript`
- C#: `dotnet tool install -g csharp-ls`

TypeScript uses project-local `tsserver` when available, falls back to global.
C# root detection looks for `*.sln`, `*.csproj`, or `.git`.

## Key conventions

- Leader is `<Space>`
- Adding a new plugin: add to `vim.pack.add()` in `lua/plugins/init.lua`, create `lua/plugins/<name>.lua` for setup, require it from `init.lua`
- `lua/*.lua` modules auto-reload on save (clears `package.loaded` and re-requires)
- `init.lua` auto-reloads via `source $MYVIMRC` on save
- neoscroll owns `<C-d>`/`<C-u>` — do not remap those in `keymaps.lua`
