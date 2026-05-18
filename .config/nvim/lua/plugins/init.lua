-- =============================================================================
-- plugins/init.lua — plugin registration via vim.pack (built-in, Nvim 0.12+)
-- =============================================================================

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  -- Minimal fuzzy file picker
  gh('echasnovski/mini.pick'),

  -- Smooth scrolling
  gh('karb94/neoscroll.nvim'),

  -- Keymap hints
  gh('folke/which-key.nvim'),

  -- Theme
  gh('catppuccin/nvim'),
})

require('plugins.mini-pick')
require('plugins.neoscroll')
require('plugins.which-key')
require('plugins.catppuccin')
