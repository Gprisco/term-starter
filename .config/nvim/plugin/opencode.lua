-- =============================================================================
-- plugin/opencode.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nickjvandyke/opencode.nvim' },
  })

  vim.o.autoread = true -- required for buffer auto-reload on opencode edits

  ---@type opencode.Opts
  vim.g.opencode_opts = {}

  require('opencode')

  -- Toggle opencode panel
  vim.keymap.set({ 'n', 't' }, '<C-.>', function() require('opencode').toggle() end,   { desc = 'Toggle opencode' })

  -- Ask with current context (operator-style, supports visual selection)
  vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode' })

  -- Select from prompts / commands menu
  vim.keymap.set({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select opencode prompt' })

  -- Operator: add range to opencode
  vim.keymap.set({ 'n', 'x' }, 'go',  function() return require('opencode').operator('@this ') end,        { desc = 'Add range to opencode', expr = true })
  vim.keymap.set('n',          'goo', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Add line to opencode',  expr = true })

  -- Scroll opencode panel
  vim.keymap.set('n', '<S-C-u>', function() require('opencode').command('session.half.page.up') end,   { desc = 'Scroll opencode up' })
  vim.keymap.set('n', '<S-C-d>', function() require('opencode').command('session.half.page.down') end, { desc = 'Scroll opencode down' })
end)
