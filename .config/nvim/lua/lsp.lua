-- =============================================================================
-- lsp.lua — manual LSP configuration
-- =============================================================================

-- Diagnostic display options
vim.diagnostic.config({
  virtual_text   = true,
  signs          = true,
  underline      = true,
  update_in_insert = false,
  severity_sort  = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

-- -----------------------------------------------------------------------------
-- Format on save (LSP)
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
  desc = 'Format buffer with LSP before saving',
})

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

--- Finds the nearest ancestor dir that contains any of the given markers.
---@param markers string[]
---@return string|nil
local function find_root(markers)
  return vim.fs.root(0, markers)
end

-- -----------------------------------------------------------------------------
-- TypeScript — typescript-language-server
--
-- Uses project-local tsserver when available, falls back to global install.
-- -----------------------------------------------------------------------------
local function typescript_cmd()
  -- Look for project-local tsserver binary
  local local_ts = vim.fn.findfile(
    'node_modules/.bin/typescript-language-server',
    vim.fn.getcwd() .. ';'
  )
  if local_ts ~= '' then
    return { vim.fn.fnamemodify(local_ts, ':p') }
  end
  return { 'typescript-language-server', '--stdio' }
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  callback = function()
    local root = find_root({ 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' })
    local cmd = typescript_cmd()
    -- Append --stdio only when using the global binary (local binary is a wrapper)
    if cmd[1] == 'typescript-language-server' and not cmd[2] then
      cmd[2] = '--stdio'
    end
    vim.lsp.start({
      name    = 'tsserver',
      cmd     = cmd,
      root_dir = root or vim.fn.getcwd(),
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
      },
    })
  end,
})

-- -----------------------------------------------------------------------------
-- C# — csharp-ls  (install: dotnet tool install -g csharp-ls)
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cs',
  callback = function()
    local root = find_root({ '*.sln', '*.csproj', '.git' })
    vim.lsp.start({
      name     = 'csharp-ls',
      cmd      = { 'csharp-ls' },
      root_dir = root or vim.fn.getcwd(),
    })
  end,
})

-- -----------------------------------------------------------------------------
-- Lua — lua-language-server  (install: brew/pacman/apt install lua-language-server)
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    local root = find_root({ '.luarc.json', '.luarc.jsonc', '.git' })
    vim.lsp.start({
      name     = 'lua_ls',
      cmd      = { 'lua-language-server' },
      root_dir = root or vim.fn.getcwd(),
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',  -- Neovim uses LuaJIT
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('', true),  -- expose Neovim runtime
          },
          diagnostics = {
            globals = { 'vim' },  -- suppress "undefined global vim" warnings
          },
          telemetry = { enable = false },
        },
      },
    })
  end,
})
