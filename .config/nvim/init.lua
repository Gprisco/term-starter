-- =============================================================================
-- init.lua — entry point
-- =============================================================================

-- Leader must be set before any plugin or keymap is loaded
vim.g.mapleader        = " "
vim.g.maplocalleader   = " "

-- Basic options
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = "yes"
vim.opt.termguicolors  = true
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 2
vim.opt.tabstop        = 2
vim.opt.smartindent    = true
vim.opt.undofile       = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.updatetime     = 250
vim.opt.clipboard      = 'unnamedplus'

-- =============================================================================
-- Keymaps and LSP
-- =============================================================================
require('keymaps')
require('lsp')

-- =============================================================================
-- Auto-reload config on save
-- =============================================================================
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern  = vim.fn.stdpath('config') .. '/lua/*.lua',
  callback = function(ev)
    local modname = vim.fn.fnamemodify(ev.file, ':t:r')
    package.loaded[modname] = nil
    local ok, err = pcall(require, modname)
    if ok then
      vim.notify('Reloaded: ' .. modname, vim.log.levels.INFO)
    else
      vim.notify('Error reloading ' .. modname .. ':\n' .. err, vim.log.levels.ERROR)
    end
  end,
  desc     = 'Reload nvim config module on save',
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern  = vim.fn.stdpath('config') .. '/init.lua',
  callback = function()
    vim.cmd('source $MYVIMRC')
    vim.notify('Reloaded: init.lua', vim.log.levels.INFO)
  end,
  desc     = 'Re-source init.lua on save',
})
