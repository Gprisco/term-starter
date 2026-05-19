-- =============================================================================
-- lazyload.lua — VimEnter queue for deferred plugin setup
-- Based on https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/
-- =============================================================================

local M = {}

local vim_enter_queue = {}
local override_queue = {}

local function drain(queue)
  for _, entry in ipairs(queue) do
    if not entry.sync then
      vim.schedule(entry.fn)
    end
  end
  for _, entry in ipairs(queue) do
    if entry.sync then
      entry.fn()
    end
  end
end

local function drain_override()
  if not override_queue then return end
  for _, entry in ipairs(override_queue) do
    vim.schedule(function()
      local ok, err = pcall(entry.fn)
      if not ok then
        vim.notify((".nvim.lua override error:\n%s"):format(err), vim.log.levels.ERROR)
      end
    end)
  end
  override_queue = nil
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    drain(vim_enter_queue)
    vim_enter_queue = nil
    drain_override()
  end,
})

--- Queue fn to run after VimEnter. Pass { sync = true } for plugins that must
--- be fully set up before the UI draws (e.g. statuslines).
function M.on_vim_enter(fn, opts)
  local sync = opts and opts.sync or false
  if vim_enter_queue then
    table.insert(vim_enter_queue, { fn = fn, sync = sync })
  elseif sync then
    fn()
  else
    vim.schedule(fn)
  end
end

--- Queue fn to run after all VimEnter plugin setup (for per-project overrides).
function M.on_override(fn)
  if override_queue then
    table.insert(override_queue, { fn = fn })
  else
    vim.schedule(fn)
  end
end

return M
