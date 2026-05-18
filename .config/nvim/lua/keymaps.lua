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
