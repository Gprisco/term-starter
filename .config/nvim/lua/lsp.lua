-- =============================================================================
-- lsp.lua — manual LSP configuration
-- =============================================================================

-- Diagnostic display options
vim.diagnostic.config({
  virtual_text     = true,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = {
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
-- Feedback — notify on LSP attach and progress
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      vim.notify('LSP attached: ' .. client.name, vim.log.levels.INFO)
    end
  end,
  desc = 'Notify when LSP attaches to a buffer',
})

vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      vim.notify('LSP detached: ' .. client.name, vim.log.levels.WARN)
    end
  end,
  desc = 'Notify when LSP detaches from a buffer',
})

-- :LspStatus — show attached clients and their capabilities
vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd('edit ' .. vim.lsp.get_log_path())
end, { desc = 'Open LSP log file' })

vim.api.nvim_create_user_command('LspStatus', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local global_fallback = false
  if #clients == 0 then
    clients = vim.lsp.get_clients()
    global_fallback = true
  end
  if #clients == 0 then
    vim.notify('No LSP clients attached to this buffer', vim.log.levels.WARN)
    return
  end
  local lines = {}
  if global_fallback then
    table.insert(lines, '(no clients attached to this buffer — showing all active clients)')
    table.insert(lines, '')
  end
  for _, client in ipairs(clients) do
    local caps = client.server_capabilities
    table.insert(lines, ('• %s (id=%d)'):format(client.name, client.id))
    table.insert(lines, ('  root:       %s'):format(client.root_dir or 'n/a'))
    table.insert(lines, ('  formatting: %s'):format(
      (caps.documentFormattingProvider or caps.documentOnTypeFormattingProvider) and '✓' or '✗'))
    table.insert(lines,
      ('  hover:      %s'):format(caps.hoverProvider and '✓' or '✗'))
    table.insert(lines, ('  completion: %s'):format(caps.completionProvider and '✓' or '✗'))
    table.insert(lines, ('  references: %s'):format(caps.referencesProvider and '✓' or '✗'))
    table.insert(lines, ('  all caps:   %s'):format(vim.inspect(caps)))
    table.insert(lines, '')
  end
  -- Open in a scratch buffer so the full capability dump is readable
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(table.concat(lines, '\n'), '\n'))
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
end, { desc = 'Show LSP clients attached to current buffer' })

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
      name     = 'tsserver',
      cmd      = cmd,
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
            version = 'LuaJIT', -- Neovim uses LuaJIT
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('', true), -- expose Neovim runtime
          },
          diagnostics = {
            globals = { 'vim' }, -- suppress "undefined global vim" warnings
          },
          telemetry = { enable = false },
        },
      },
    })
  end,
})
