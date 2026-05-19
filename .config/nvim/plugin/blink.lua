-- =============================================================================
-- plugin/blink.lua — completion via blink.cmp
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/saghen/blink.cmp' },
  })

  require('blink.cmp').setup({
    keymap = {
      preset = 'default',
      ['<CR>'] = { 'accept', 'fallback' },
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
    sources = {
      default = { 'lsp', 'path', 'buffer' },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
    },
    signature = { enabled = true },
  })
end)
