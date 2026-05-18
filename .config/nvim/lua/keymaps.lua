-- =============================================================================
-- keymaps.lua — global keymaps
-- =============================================================================

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- -----------------------------------------------------------------------------
-- File picker (mini.pick)
-- -----------------------------------------------------------------------------
map('n', '<leader>ff', function() require('mini.pick').builtin.files() end,       { desc = 'Find files' })
map('n', '<leader>fg', function() require('mini.pick').builtin.grep_live() end,   { desc = 'Live grep' })
map('n', '<leader>fb', function() require('mini.pick').builtin.buffers() end,     { desc = 'Find buffers' })
map('n', '<leader>fh', function() require('mini.pick').builtin.help() end,        { desc = 'Find help' })

-- -----------------------------------------------------------------------------
-- LSP — custom keymaps (rest use Nvim built-in lsp-defaults: gd, grr, K, etc.)
-- -----------------------------------------------------------------------------
map('n', '<leader>rn', vim.lsp.buf.rename,      { desc = 'Rename symbol' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
