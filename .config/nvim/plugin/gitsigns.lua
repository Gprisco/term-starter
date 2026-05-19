-- =============================================================================
-- plugin/gitsigns.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  })

  require('gitsigns').setup({
    signs = {
      add          = { text = '▎' },
      change       = { text = '▎' },
      delete       = { text = '▁' },
      topdelete    = { text = '▔' },
      changedelete = { text = '▎' },
      untracked    = { text = '▎' },
    },
    current_line_blame = false, -- toggle with <leader>gb
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map('n', ']h', function() gs.nav_hunk('next') end, 'Next hunk')
      map('n', '[h', function() gs.nav_hunk('prev') end, 'Prev hunk')

      -- Actions
      map('n', '<leader>hs', gs.stage_hunk,                                                          'Stage hunk')
      map('n', '<leader>hr', gs.reset_hunk,                                                          'Reset hunk')
      map('x', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,  'Stage hunk (range)')
      map('x', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,  'Reset hunk (range)')
      map('n', '<leader>hS', gs.stage_buffer,                                                        'Stage buffer')
      map('n', '<leader>hR', gs.reset_buffer,                                                        'Reset buffer')
      map('n', '<leader>hu', gs.undo_stage_hunk,                                                     'Undo stage hunk')
      map('n', '<leader>hp', gs.preview_hunk,                                                        'Preview hunk')
      map('n', '<leader>hd', gs.diffthis,                                                            'Diff this')

      -- Blame
      map('n', '<leader>gb', gs.toggle_current_line_blame, 'Toggle git blame')

      -- Text object: select hunk with ih
      map({ 'o', 'x' }, 'ih', ':<C-u>Gitsigns select_hunk<cr>', 'Select hunk')
    end,
  })

  -- :GitBlame command as an alias for toggling inline blame
  vim.api.nvim_create_user_command('GitBlame', function()
    require('gitsigns').toggle_current_line_blame()
  end, { desc = 'Toggle git blame' })
end)
