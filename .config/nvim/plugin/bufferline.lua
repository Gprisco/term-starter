-- =============================================================================
-- plugin/bufferline.lua
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim' },
  })

  require('bufferline').setup({
    options = {
      mode            = 'buffers',
      separator_style = 'slant',
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
    },
  })
end)
