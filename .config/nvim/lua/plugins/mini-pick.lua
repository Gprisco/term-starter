-- =============================================================================
-- plugins/mini-pick.lua
-- =============================================================================

require('mini.pick').setup({
  mappings = {
    move_down = '<C-n>',
    move_up   = '<C-p>',
  },
  window = {
    config = { border = 'rounded' },
  },
})
