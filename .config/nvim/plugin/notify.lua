-- =============================================================================
-- plugin/noice.lua — toast notifications (replaces cmdline + notify UI)
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/rcarriga/nvim-notify' },
  })

  require('notify').setup({
    stages   = 'fade_in_slide_out',
    timeout  = 3000,
    max_width = 60,
    icons = {
      ERROR = '',
      WARN  = '',
      INFO  = '',
      DEBUG = '',
      TRACE = '✎',
    },
  })

  vim.notify = require('notify')
end)
