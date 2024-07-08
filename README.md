# term-starter
Some basic configuration for easily get my shell and neovim setup.

## Usage
Some tools are required, like **zsh** shell, [fzf](https://github.com/junegunn/fzf),
[zoxide](https://github.com/ajeetdsouza/zoxide) and [neovim](https://neovim.io/).

After getting these tools, the script included in the repo will copy a
configuration for neovim into `~/.config/neovim` and a zsh profile into `~/.zshrc`.
Just run

```bash
./install.sh
```

or

```powershell
.\install.ps1
```

### Sync nvim config changes
I usually update the configuration in `~/.config/nvim` and then copy the updates
here before committing them.

A script which helps me do so is:

```bash
./syncNvimConfig.sh
```

## Environment variables
If on windows, then set the HOME environment variable to be the user profile home.

## LSP
Omnisharp is required to be in `$HOME/lsp/omnisharp`.
