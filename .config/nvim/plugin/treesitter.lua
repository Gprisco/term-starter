-- =============================================================================
-- plugin/treesitter.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', branch = 'main' },
  })

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      if ev.data.spec.name == 'nvim-treesitter' then
        vim.cmd('TSUpdate')
      end
    end,
  })

  require('nvim-treesitter').setup({
    ensure_installed = {
      'lua', 'typescript', 'javascript', 'tsx', 'c_sharp',
      'json', 'yaml', 'toml', 'markdown', 'markdown_inline',
      'bash', 'regex', 'vim', 'vimdoc',
    },
    highlight = { enable = true },
    indent    = { enable = true },
  })
end)
