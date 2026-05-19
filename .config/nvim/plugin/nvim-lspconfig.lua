-- =============================================================================
-- plugin/nvim-lspconfig.lua — install nvim-lspconfig (config registry only)
--
-- nvim-lspconfig ships LSP server default configs into the runtimepath.
-- vim.lsp.config() and vim.lsp.enable() (Nvim 0.11+) pick them up automatically.
-- require('lspconfig') is NOT used — it is deprecated.
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
  })
end)
