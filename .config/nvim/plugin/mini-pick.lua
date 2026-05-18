-- =============================================================================
-- plugin/mini-pick.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/echasnovski/mini.pick' },
  })

  require('mini.pick').setup({
    mappings = {
      move_down = '<C-n>',
      move_up   = '<C-p>',
    },
    window = {
      config = { border = 'rounded' },
    },
  })
end)
