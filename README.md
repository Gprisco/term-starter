# term-starter

Dotfiles/config starter: copies a Neovim config and `.zshrc` to the right locations.

## Requirements

- [zsh](https://www.zsh.org/)
- [mise](https://mise.jdx.dev/) — installs and versions every other tool here
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal (for file icons)

Install mise first, then let `./install.sh` do the rest:

```bash
# official installer, any platform
curl https://mise.run | sh

# or, on macOS
brew install mise
```

Neovim 0.12+, fzf, zoxide, ripgrep, node, pnpm, bun, typescript, Go, .NET,
opencode and all three language servers are declared in [`mise.toml`](mise.toml)
— the installer puts them on your `PATH` via mise shims.

## Usage

**Edit files here, deploy with the install script — never edit `~/.config/nvim` directly.**

```bash
./install.sh          # deploy .config/nvim → ~/.config/nvim, link mise.toml, install tools
./install.sh --zshrc  # ...and also overwrite ~/.zshrc with this repo's (backs up first)
./syncNvimConfig.sh   # pull changes back from ~/.config/nvim into repo (before committing)
```

`--zshrc` is opt-in because a machine may already have a hand-written `~/.zshrc`
that this template would replace.

On Windows — `mise` is **not** wired up here, so install Neovim, `lua-language-server`,
`typescript-language-server` and the Roslyn language server yourself:

```powershell
.\install.ps1         # copies .config/nvim to %LOCALAPPDATA%\nvim
```

## Toolchain (mise)

`mise.toml` pins every tool to an exact version; `mise.lock` records the resolved
artifact URLs and checksums. `install.sh` symlinks both into `~/.config/mise/`, so
`config.toml` always points at this repo:

```
~/.config/mise/config.toml -> <repo>/mise.toml
~/.config/mise/mise.lock   -> <repo>/mise.lock
```

Because they are symlinks, mise writes lock updates straight back into the repo —
nothing to sync by hand.

```bash
mise ls                       # resolved versions
mise doctor                   # activation + shims sanity check
mise which node               # real path behind the shim
mise install                  # install anything missing
mise upgrade <tool>@<version> # jump to another version
mise lock --bump <tool>       # re-resolve one tool, then commit mise.toml + mise.lock
```

The shell is configured in `.zshrc` with **shims mode**:

```zsh
eval "$(mise activate zsh --shims)"
```

Shims mode puts `~/.local/share/mise/shims` on `PATH`, which means tools also
resolve for processes that never run a mise prompt — Neovim spawning language
servers, fzf previews, git hooks, GUI-launched apps. The trade-off is that mise
`[env]` vars are applied to mise-managed processes only, so things like
`JAVA_HOME` are *not* exported into your interactive shell. See
[java.md](java.md) for a concrete case where that matters.

`java` is currently the one tool in the repo's former toolchain that mise does
**not** manage.

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

Servers are enabled in [`lua/lsp.lua`](.config/nvim/lua/lsp.lua) via
`vim.lsp.enable`. No mason.nvim — the server *binaries* come from `mise`, and
nvim-lspconfig supplies the filetypes, root detection and command handlers.

| Server | Installed by mise | Started as |
|---|---|---|
| `ts_ls` | `npm:typescript-language-server` + `npm:typescript` | project-local `node_modules/.bin` if present, else the mise shim |
| `lua_ls` | `lua-language-server` | `lua-language-server` on `PATH` |
| `roslyn_ls` | `dotnet:roslyn-language-server` | `roslyn-language-server` on `PATH` |

To add a server: optionally call `vim.lsp.config('server_name', { ... })` in
`lua/lsp.lua` to override nvim-lspconfig's defaults, add the name to the
`vim.lsp.enable({ ... })` call at the bottom of that file, then declare the
binary in `mise.toml` and run `./install.sh`.

### TypeScript — ts_ls

`typescript-language-server` ships with **no dependencies**: it resolves
`typescript` from the workspace's `node_modules` first, then from
`tsserver.fallbackPath`, then from its own (empty) install directory. Because
mise gives every npm package its own directory, the sibling-copy trick
`npm i -g typescript-language-server typescript` relied on cannot work — so
`lua/lsp.lua` points the fallback at the `npm:typescript` install from
`mise.toml`. Scratch `.ts` files with no `node_modules` get a working server,
while a project with its own `typescript` still uses its pinned version.
Keep typescript `< 7` for now: ts_ls does not support TS 7 yet.

### C# — Roslyn

`roslyn-language-server` is Microsoft's own .NET language server (the one behind
the VS Code C# extension): full hover, go-to-def into decompiled sources, code
actions, Razor support. `mise.toml` installs it as a dotnet global tool pinned to
a version matching VS Code's C# extension.

nvim-lspconfig's `roslyn_ls` config already resolves the binary from `PATH`, so
`lua/lsp.lua` sets no `cmd`. When opening a `.cs` file it auto-detects solution
files (`*.sln`) upward in the directory tree.

Bump it when VS Code's C# extension moves ahead:

```bash
mise lock --bump dotnet:roslyn-language-server
```

To switch to the current release candidate line instead of the latest stable,
add `prerelease = true` to the tool's options in `mise.toml` and re-lock.

### Windows

`install.ps1` deploys only the Neovim config — no mise. Install the servers by
hand: `npm install -g typescript-language-server typescript` (typescript needs
to be `< 7`, and the shared global `node_modules` is what lets the server find
it), `lua-language-server` from its GitHub releases, and the Roslyn language
server from the
[`roslyn-language-server`](https://www.nuget.org/packages/roslyn-language-server)
package (`dotnet tool install --global roslyn-language-server --prerelease`).

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
