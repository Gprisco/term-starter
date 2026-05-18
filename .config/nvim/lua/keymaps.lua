-- =============================================================================
-- keymaps.lua — global keymaps
-- =============================================================================

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- -----------------------------------------------------------------------------
-- Editing
-- -----------------------------------------------------------------------------
map('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- Navigation: <C-d>/<C-u> centering is handled via neoscroll post_hook in plugins.lua

-- -----------------------------------------------------------------------------
-- Explorer
-- -----------------------------------------------------------------------------
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file explorer' })

-- -----------------------------------------------------------------------------
-- Window navigation
-- -----------------------------------------------------------------------------
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })

-- -----------------------------------------------------------------------------
-- Buffers
-- -----------------------------------------------------------------------------
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Close buffer' })

-- -----------------------------------------------------------------------------
-- File picker (mini.pick)
-- -----------------------------------------------------------------------------

--- Opens git files if inside a git repo, falls back to all files in cwd.
local function find_project_files()
  local is_git = vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1] == 'true'
  if is_git then
    require('mini.pick').builtin.files({ tool = 'git' })
  else
    require('mini.pick').builtin.files()
  end
end

map('n', '<leader><leader>', find_project_files,                                   { desc = 'Find project files' })
map('n', '<leader>ff',       function() require('mini.pick').builtin.files() end,  { desc = 'Find files' })
map('n', '<leader>fg',       function() require('mini.pick').builtin.grep_live() end, { desc = 'Live grep' })
map('n', '<leader>fb',       function() require('mini.pick').builtin.buffers() end,   { desc = 'Find buffers' })
map('n', '<leader>fh',       function() require('mini.pick').builtin.help() end,      { desc = 'Find help' })

-- -----------------------------------------------------------------------------
-- LSP — custom keymaps (rest use Nvim built-in lsp-defaults: gd, grr, K, etc.)
-- -----------------------------------------------------------------------------
map('n', '<leader>rn', vim.lsp.buf.rename,      { desc = 'Rename symbol' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })

-- -----------------------------------------------------------------------------
-- Diagnostics
-- -----------------------------------------------------------------------------
map('n', '<leader>d',  function() vim.diagnostic.open_float() end,               { desc = 'Show diagnostics' })
map('n', ']d',         function() vim.diagnostic.goto_next() end,                 { desc = 'Next diagnostic' })
map('n', '[d',         function() vim.diagnostic.goto_prev() end,                 { desc = 'Prev diagnostic' })
map('n', '<leader>dl', function() vim.diagnostic.setloclist() end,                { desc = 'Diagnostics to loclist' })
