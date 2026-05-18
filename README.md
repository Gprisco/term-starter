# term-starter

Dotfiles/config starter: copies a Neovim config and `.zshrc` to the right locations.

## Requirements

- [zsh](https://www.zsh.org/)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [Neovim](https://neovim.io/) 0.12+
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal (for file icons)

## Usage

**Edit files here, deploy with the install script — never edit `~/.config/nvim` directly.**

```bash
./install.sh          # deploy .config/nvim → ~/.config/nvim and .zshrc → ~/.zshrc
./syncNvimConfig.sh   # pull changes back from ~/.config/nvim into repo (before committing)
```

On Windows:

```powershell
.\install.ps1         # copies .config/nvim to %LOCALAPPDATA%\nvim
```

## Neovim plugins

Plugins are managed by **`vim.pack`** (Neovim 0.12+ built-in). No lazy.nvim or other external manager.

On first launch Neovim will prompt to confirm plugin installation. To update plugins later:

```
:lua vim.pack.update()
```

Installed plugins:

| Plugin | Purpose |
|---|---|
| catppuccin/nvim | Colorscheme |
| nvim-tree/nvim-web-devicons | File icons |
| akinsho/bufferline.nvim | Buffer tabs at the top |
| nvim-tree/nvim-tree.lua | File explorer |
| echasnovski/mini.pick | Fuzzy file/grep/buffer picker |
| folke/which-key.nvim | Keymap hints |
| karb94/neoscroll.nvim | Smooth scrolling |
| lewis6991/gitsigns.nvim | Git hunks, blame, staging |
| rcarriga/nvim-notify | Toast notifications |
| nvim-treesitter/nvim-treesitter | Syntax highlighting and indentation |
| nickjvandyke/opencode.nvim | OpenCode AI integration |
| seblyng/roslyn.nvim | C# Roslyn LSP integration |
| j-hui/fidget.nvim | LSP progress notifications |

## LSP

Manual LSP config via `FileType` autocmds. No mason.nvim.

### TypeScript / JavaScript

```bash
npm i -g typescript-language-server typescript
```

### C# — Roslyn (roslyn.nvim)

Uses the same Roslyn language server as the VS Code C# extension — full hover, go-to-def into decompiled sources, code actions, and more.

Download the linux-x64 nuget package and extract it to `~/.roslyn/`:

```bash
VERSION="5.0.0-1.25277.114"  # check latest at https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.linux-x64/index.json
curl -L -o /tmp/roslyn.nupkg \
  "https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.linux-x64/${VERSION}/microsoft.codeanalysis.languageserver.linux-x64.${VERSION}.nupkg"
mkdir -p ~/.roslyn
unzip /tmp/roslyn.nupkg "content/LanguageServer/linux-x64/*" -d /tmp/roslyn_extract
cp -r /tmp/roslyn_extract/content/LanguageServer/linux-x64/. ~/.roslyn/
chmod +x ~/.roslyn/Microsoft.CodeAnalysis.LanguageServer
```

When opening a `.cs` file, roslyn.nvim auto-detects solution files (`.sln`) upward in the directory tree. If multiple are found, use `:Roslyn target` to pick one.

Commands: `:Roslyn start` / `stop` / `restart` / `target`

### Lua

```bash
# macOS
brew install lua-language-server

# Arch
sudo pacman -S lua-language-server

# Debian/Ubuntu
sudo apt install lua-language-server
```

## Key mappings (highlights)

| Keymap | Action |
|---|---|
| `<leader><leader>` | Find project files |
| `<leader>ff/fg/fb/fh` | Find files / grep / buffers / help |
| `<leader>e` | Toggle file explorer |
| `<C-h/j/k/l>` | Navigate between windows |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `]h` / `[h` | Next / prev git hunk |
| `<leader>hp` | Preview hunk |
| `<leader>gb` | Toggle git blame / `:GitBlame` |
| `gd` / `gI` / `gr` | LSP definition / implementation / references |
| `K` | LSP hover docs |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>d` | Show diagnostics float |
| `<C-.>` | Toggle OpenCode panel |
| `<leader>oa` | Ask OpenCode |
| `:LspStatus` | Show attached LSP clients and capabilities |
| `:GitBlame` | Toggle inline git blame |
