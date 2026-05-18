-- =============================================================================
-- plugins/which-key.lua
-- =============================================================================

local wk = require('which-key')

wk.setup({
  preset = 'modern',
  delay  = 300,
})

wk.add({
  { '<leader>r', group = 'rename' },
  { '<leader>c', group = 'code' },
  { '<leader>f', group = 'find' },
})
