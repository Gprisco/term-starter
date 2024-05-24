require("gio.remap")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("gio.plugins.telescope"),
	require("gio.plugins.theme"),
	require("gio.plugins.treesitter")
})

require("gio.plugins.telescope_config")
require("gio.plugins.theme_config")
require("gio.plugins.treesitter_config")
