-- =============================================================================
-- plugin/which-key.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/folke/which-key.nvim' },
  })

  local wk = require('which-key')

  wk.setup({
    preset = 'modern',
    delay  = 300,
  })

  wk.add({
    { '<leader>r', group = 'rename' },
    { '<leader>c', group = 'code' },
    { '<leader>f', group = 'find' },
    { '<leader>b', group = 'buffer' },
  })
end)
