-- =============================================================================
-- plugin/devicons.lua — file icons (eager: used by bufferline, nvim-tree, etc.)
-- =============================================================================

vim.pack.add({
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
})

require('nvim-web-devicons').setup({ default = true })
