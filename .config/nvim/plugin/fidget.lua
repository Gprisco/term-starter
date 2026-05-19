-- =============================================================================
-- plugin/fidget.lua — LSP progress notifications in the corner
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/j-hui/fidget.nvim' },
  })

  require('fidget').setup({
    notification = {
      window = {
        winblend = 0, -- fully opaque; set to 100 for transparent
      },
    },
  })
end)
