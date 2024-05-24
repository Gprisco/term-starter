require('gio.remap')
require('gio.set')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.7',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{{ 'rose-pine/neovim', name = 'rose-pine' }},
	{{ 'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdate' }},
	{
		'ThePrimeagen/harpoon',
		branch = 'harpoon2',
		dependencies = { 'nvim-lua/plenary.nvim' }
	}
})
