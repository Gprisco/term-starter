-- =============================================================================
-- plugins/catppuccin.lua
-- =============================================================================

require('catppuccin').setup({
  flavour = 'mocha',
  integrations = {
    mini = { enabled = true },
    which_key = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors      = { 'undercurl' },
        hints       = { 'undercurl' },
        warnings    = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
  },
})

vim.cmd.colorscheme('catppuccin')
