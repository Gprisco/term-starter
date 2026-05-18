-- =============================================================================
-- plugins.lua — plugin management via vim.pack (built-in, Nvim 0.12+)
-- =============================================================================

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  -- Minimal fuzzy file picker
  gh('echasnovski/mini.pick'),

  -- Keymap hints
  gh('folke/which-key.nvim'),
})

-- -----------------------------------------------------------------------------
-- mini.pick setup
-- -----------------------------------------------------------------------------
require('mini.pick').setup({
  mappings = {
    move_down  = '<C-j>',
    move_up    = '<C-k>',
  },
  window = {
    config = { border = 'rounded' },
  },
})

-- -----------------------------------------------------------------------------
-- which-key setup
-- -----------------------------------------------------------------------------
require('which-key').setup({
  preset = 'modern',
  delay  = 300,
})

-- Register leader group labels so which-key shows them nicely
require('which-key').add({
  { '<leader>r', group = 'rename' },
  { '<leader>c', group = 'code' },
  { '<leader>f', group = 'find' },
})
