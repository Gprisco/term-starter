-- =============================================================================
-- plugin/nvim-tree.lua
-- =============================================================================

-- Must be set before nvim-tree loads
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  })

  require('nvim-tree').setup({
    view = {
      side  = 'left',
      width = 35,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
  })
end)
