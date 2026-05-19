-- =============================================================================
-- lsp.lua — LSP configuration
--
-- Uses vim.lsp.config / vim.lsp.enable (Nvim 0.11+ API).
-- nvim-lspconfig provides default server configs via the runtimepath;
-- entries here extend/override those defaults.
-- require('lspconfig') is intentionally NOT used — it is deprecated.
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
-- Feedback — notify on LSP attach / detach
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

-- -----------------------------------------------------------------------------
-- Commands
-- -----------------------------------------------------------------------------

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
    table.insert(lines, ('  hover:      %s'):format(caps.hoverProvider and '✓' or '✗'))
    table.insert(lines, ('  completion: %s'):format(caps.completionProvider and '✓' or '✗'))
    table.insert(lines, ('  references: %s'):format(caps.referencesProvider and '✓' or '✗'))
    table.insert(lines, ('  all caps:   %s'):format(vim.inspect(caps)))
    table.insert(lines, '')
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(table.concat(lines, '\n'), '\n'))
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
end, { desc = 'Show LSP clients attached to current buffer' })

-- -----------------------------------------------------------------------------
-- TypeScript — ts_ls (typescript-language-server)
--
-- Prefers project-local tsserver binary when available, falls back to global.
-- nvim-lspconfig provides the default config (filetypes, root markers, etc.);
-- we only override cmd and settings here.
-- -----------------------------------------------------------------------------

---@return string[]
local function typescript_cmd()
  local local_ts = vim.fn.findfile(
    'node_modules/.bin/typescript-language-server',
    vim.fn.getcwd() .. ';'
  )
  if local_ts ~= '' then
    return { vim.fn.fnamemodify(local_ts, ':p'), '--stdio' }
  end
  return { 'typescript-language-server', '--stdio' }
end

vim.lsp.config('ts_ls', {
  cmd = typescript_cmd(),
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints          = 'all',
        includeInlayFunctionParameterTypeHints  = true,
        includeInlayVariableTypeHints           = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints          = 'all',
        includeInlayFunctionParameterTypeHints  = true,
        includeInlayVariableTypeHints           = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
  },
})

-- -----------------------------------------------------------------------------
-- Lua — lua-language-server
--
-- nvim-lspconfig provides the default config; we override settings for
-- Neovim-specific development (LuaJIT runtime, vim global, full runtime lib).
-- -----------------------------------------------------------------------------

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = {
        globals = { 'vim' },
      },
      telemetry = { enable = false },
    },
  },
})

-- -----------------------------------------------------------------------------
-- C# — roslyn_ls (Microsoft.CodeAnalysis.LanguageServer)
--
-- nvim-lspconfig provides the full roslyn_ls config: filetypes, handlers,
-- commands (fixAllCodeAction, nestedCodeAction, completionComplexEdit), and
-- on_attach/on_init. We only override cmd and settings here.
--
-- Server binary: extract the linux-x64 nuget to ~/.roslyn/ (see AGENTS.md).
-- -----------------------------------------------------------------------------

vim.lsp.config('roslyn_ls', {
  cmd = {
    'dotnet',
    vim.fs.joinpath(vim.uv.os_homedir(), '.roslyn', 'Microsoft.CodeAnalysis.LanguageServer.dll'),
    '--logLevel', 'Information',
    '--extensionLogDirectory', vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
    '--stdio',
  },
  settings = {
    ['csharp|inlay_hints'] = {
      csharp_enable_inlay_hints_for_implicit_object_creation              = true,
      csharp_enable_inlay_hints_for_implicit_variable_types               = true,
      dotnet_enable_inlay_hints_for_parameters                            = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
    },
    ['csharp|completion'] = {
      dotnet_show_completion_items_from_unimported_namespaces = true,
    },
    ['csharp|formatting'] = {
      dotnet_organize_imports_on_format = true,
    },
  },
})

-- CSFixUsings — remove unnecessary using directives in the current buffer
vim.api.nvim_create_user_command('CSFixUsings', function()
  local bufnr   = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = 'roslyn_ls' })
  if not clients or vim.tbl_isempty(clients) then
    vim.notify("Couldn't find Roslyn client", vim.log.levels.ERROR, { title = 'Roslyn' })
    return
  end
  local client = clients[1]
  local action = {
    kind = 'quickfix',
    data = {
      CustomTags       = { 'RemoveUnnecessaryImports' },
      TextDocument     = { uri = vim.uri_from_bufnr(bufnr) },
      CodeActionPath   = { 'Remove unnecessary usings' },
      Range            = {
        ['start'] = { line = 0, character = 0 },
        ['end']   = { line = 0, character = 0 },
      },
      UniqueIdentifier = 'Remove unnecessary usings',
    },
  }
  client:request('codeAction/resolve', action, function(err, resolved_action)
    if err then
      vim.notify('Fix using directives failed', vim.log.levels.ERROR, { title = 'Roslyn' })
      return
    end
    vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
  end)
end, { desc = 'Remove unnecessary using directives' })

-- Auto-complete XML doc comments on '///' via textDocument/_vs_onAutoInsert
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr  = args.buf
    if not client or client.name ~= 'roslyn_ls' then return end

    vim.api.nvim_create_autocmd('InsertCharPre', {
      desc     = 'Roslyn: trigger auto insert on "/"',
      buffer   = bufnr,
      callback = function()
        if vim.v.char ~= '/' then return end
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row, col       = row - 1, col + 1
        local uri      = vim.uri_from_bufnr(bufnr)
        local params   = {
          _vs_textDocument = { uri = uri },
          _vs_position     = { line = row, character = col },
          _vs_ch           = '/',
          _vs_options      = {
            tabSize      = vim.bo[bufnr].tabstop,
            insertSpaces = vim.bo[bufnr].expandtab,
          },
        }
        vim.defer_fn(function()
          client:request(
            'textDocument/_vs_onAutoInsert',
            params,
            function(err, result)
              if err or not result then return end
              vim.snippet.expand(result._vs_textEdit.newText)
            end,
            bufnr
          )
        end, 1)
      end,
    })
  end,
  desc = 'Roslyn: set up _vs_onAutoInsert for XML doc comments',
})

-- -----------------------------------------------------------------------------
-- Enable servers
-- nvim-lspconfig default configs handle filetypes and root marker detection.
-- -----------------------------------------------------------------------------

vim.lsp.enable({ 'ts_ls', 'lua_ls', 'roslyn_ls' })
