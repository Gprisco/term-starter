-- =============================================================================
-- plugin/roslyn.lua — Roslyn LSP (replaces csharp-ls for C#)
--
-- Server binary: download linux-x64 nuget from Azure DevOps and extract to
--   ~/.roslyn/  (see AGENTS.md for instructions)
-- =============================================================================

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/seblyng/roslyn.nvim' },
  })

  -- Point roslyn.nvim at the extracted server binary
  vim.lsp.config('roslyn', {
    cmd = {
      "dotnet",
      vim.fs.joinpath(vim.uv.os_homedir(), ".roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll"),
      "--logLevel", "Information",
      "--extensionLogDirectory", vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
      "--stdio",
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

  require('roslyn').setup()

  -- ---------------------------------------------------------------------------
  -- Dotnet restore progress — show fidget notifications for project restores
  -- ---------------------------------------------------------------------------
  local restore_handles = {}

  vim.api.nvim_create_autocmd('User', {
    pattern  = 'RoslynRestoreProgress',
    callback = function(ev)
      local token  = ev.data.params[1]
      local handle = restore_handles[token]
      if handle then
        handle:report({
          title   = ev.data.params[2].state,
          message = ev.data.params[2].message,
        })
      else
        restore_handles[token] = require('fidget.progress').handle.create({
          title      = ev.data.params[2].state,
          message    = ev.data.params[2].message,
          lsp_client = { name = 'roslyn' },
        })
      end
    end,
    desc     = 'Show dotnet restore progress via fidget',
  })

  vim.api.nvim_create_autocmd('User', {
    pattern  = 'RoslynRestoreResult',
    callback = function(ev)
      local handle = restore_handles[ev.data.token]
      restore_handles[ev.data.token] = nil
      if handle then
        handle.message = ev.data.err and ev.data.err.message or 'Restore completed'
        handle:finish()
      end
    end,
    desc     = 'Finish dotnet restore progress notification',
  })

  -- ---------------------------------------------------------------------------
  -- Diagnostic refresh — re-request diagnostics after leaving insert mode
  -- ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('InsertLeave', {
    pattern  = '*',
    callback = function()
      local clients = vim.lsp.get_clients({ name = 'roslyn' })
      if not clients or #clients == 0 then return end
      local client = clients[1]
      local buffers = vim.lsp.get_buffers_by_client_id(client.id)
      for _, buf in ipairs(buffers) do
        local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
        client:request('textDocument/diagnostic', params, nil, buf)
      end
    end,
    desc     = 'Refresh Roslyn diagnostics on InsertLeave',
  })

  -- ---------------------------------------------------------------------------
  -- CSFixUsings — remove unnecessary using directives in the current buffer
  -- ---------------------------------------------------------------------------
  vim.api.nvim_create_user_command('CSFixUsings', function()
    local bufnr   = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ name = 'roslyn' })
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

  -- ---------------------------------------------------------------------------
  -- textDocument/_vs_onAutoInsert — auto-complete XML doc comments on '///'
  -- ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr  = args.buf
      if not client or (client.name ~= 'roslyn' and client.name ~= 'roslyn_ls') then
        return
      end
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
end)
