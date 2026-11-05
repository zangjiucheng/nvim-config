-- File windows use :mksession; Neo-tree is recreated through its own API.
local M = {}
local pending

local function restore_trees(trees)
  if not trees or #trees == 0 then
    return
  end
  local ok, command = pcall(require, "neo-tree.command")
  if not ok then
    return
  end
  local active_tab = vim.api.nvim_get_current_tabpage()
  local active_win = vim.api.nvim_get_current_win()
  local tabs = vim.api.nvim_list_tabpages()
  for _, tree in ipairs(trees) do
    local tab = tabs[tree.tab]
    if tab and vim.api.nvim_tabpage_is_valid(tab) then
      vim.api.nvim_set_current_tabpage(tab)
      -- Acquire each window in its own tab immediately. Filesystem navigation
      -- is debounced by Neo-tree and may otherwise run after we switch tabs.
      local manager = require("neo-tree.sources.manager")
      local state = manager.get_state(tree.source, tab)
      state.window = vim.tbl_extend("force", state.window, { width = tree.width })
      state.current_position = tree.position
      state._no_focus = true
      local renderer = require("neo-tree.ui.renderer")
      renderer.acquire_window(state)
      state.force_open_folders = tree.expanded
      -- Navigation is debounced. Restore selection and focus after this
      -- particular tree renders, rather than racing a fixed startup delay.
      local events = require("neo-tree.events")
      local handler = {
        event = events.AFTER_RENDER,
        id = "session-tree-" .. tab .. "-" .. tree.source,
      }
      handler.handler = function(rendered)
        if rendered.tabid ~= tab or rendered.name ~= tree.source then
          return
        end
        handler.cancelled = true
        -- Neo-tree queues its current-file navigation callback after render.
        -- Run after that callback so the saved selection wins on startup.
        vim.schedule(function()
          if not rendered.winid or not vim.api.nvim_win_is_valid(rendered.winid) then
            return
          end
          renderer.position.clear(rendered)
          if tree.view then
            vim.api.nvim_win_call(rendered.winid, function()
              vim.fn.winrestview(tree.view)
            end)
          end
          if tree.selected then
            renderer.focus_node(rendered, tree.selected, true)
          end
          if tree.focused then
            vim.api.nvim_set_current_win(rendered.winid)
          end
        end)
      end
      events.unsubscribe(handler)
      events.subscribe(handler)
      -- The directory may be unchanged on a manual save, but its buffer was
      -- recreated and still needs a render before restoring the selection.
      state.dirty = true
      command.execute({ action = "show", source = tree.source, position = tree.position, dir = tree.dir }, {
        window = { width = tree.width },
      })
    end
  end
  if vim.api.nvim_tabpage_is_valid(active_tab) then
    vim.api.nvim_set_current_tabpage(active_tab)
  end
  if vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_set_current_win(active_win)
  end
end

local function restore_views(layout, screen)
  local width_scale = screen and vim.o.columns / screen.columns or 1
  local height_scale = screen and vim.o.lines / screen.lines or 1
  local active_tab = vim.api.nvim_get_current_tabpage()
  local active_win = vim.api.nvim_get_current_win()
  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local saved = layout and layout[index]
    if saved then
      vim.api.nvim_set_current_tabpage(tab)
      local i = 0
      local windows = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" and not vim.b[buf].neo_tree_source then
          i = i + 1
          local view = saved[i]
          if view then
            vim.api.nvim_win_set_width(win, math.max(1, math.floor(view.width * width_scale)))
            table.insert(windows, { win = win, saved = view })
          end
        end
      end
      -- Resize outer frames first, then their nested splits. Resizing a tall
      -- neighbour last can redistribute the heights of an entire split column.
      for j = #windows, 1, -1 do
        vim.api.nvim_win_set_height(windows[j].win, math.max(1, math.floor(windows[j].saved.height * height_scale)))
      end
      for _, window in ipairs(windows) do
        vim.api.nvim_win_call(window.win, function()
          vim.fn.winrestview(window.saved.view)
        end)
      end
    end
  end
  vim.api.nvim_set_current_tabpage(active_tab)
  if vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_set_current_win(active_win)
  end
end

function M.before_save()
  pending = { trees = {}, windows = {}, layout = {}, screen = { columns = vim.o.columns, lines = vim.o.lines } }
  local tree_windows = {}
  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    pending.layout[index] = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "neo-tree" then
        local source = vim.b[buf].neo_tree_source or "filesystem"
        local state = require("neo-tree.sources.manager").get_state(source, tab)
        table.insert(tree_windows, { win = win, state = state })
        local position = vim.b[buf].neo_tree_position
        if position == "left" or position == "right" then
          local node = state.tree and state.tree:get_node()
          table.insert(pending.trees, {
            tab = index,
            source = source,
            position = position,
            dir = state.path,
            width = vim.api.nvim_win_get_width(win),
            expanded = state.tree and require("neo-tree.ui.renderer").get_expanded_nodes(state.tree) or nil,
            selected = node and node:get_id() or nil,
            view = vim.api.nvim_win_call(win, vim.fn.winsaveview),
            focused = win == vim.api.nvim_get_current_win(),
          })
        end
      else
        table.insert(pending.layout[index], {
          width = vim.api.nvim_win_get_width(win),
          height = vim.api.nvim_win_get_height(win),
          view = vim.api.nvim_win_call(win, vim.fn.winsaveview),
        })
        pending.windows[win] = { winbar = vim.wo[win].winbar, foldtext = vim.wo[win].foldtext }
        -- These may call lazy plugin functions that don't exist during restore.
        vim.wo[win].winbar = ""
        vim.wo[win].foldtext = ""
      end
    end
  end
  for _, tree in ipairs(tree_windows) do
    local win = tree.win
    if vim.api.nvim_win_is_valid(win) then
      local tab = vim.api.nvim_win_get_tabpage(win)
      if #vim.api.nvim_tabpage_list_wins(tab) == 1 then
        vim.api.nvim_win_call(win, function()
          vim.cmd("enew")
        end)
      else
        require("neo-tree.ui.renderer").close(tree.state, false)
      end
    end
  end
end

function M.save_extra()
  return vim.json.encode({
    trees = pending and pending.trees or {},
    layout = pending and pending.layout or {},
    screen = pending and pending.screen,
  })
end

function M.after_save()
  if not pending then
    return
  end
  for win, options in pairs(pending.windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winbar = options.winbar
      vim.wo[win].foldtext = options.foldtext
    end
  end
  -- No need to reopen panels while quitting, but a manual save should leave
  -- the current workspace looking as it did before the save.
  if vim.v.exiting == vim.NIL or vim.v.exiting == nil then
    restore_trees(pending.trees)
    restore_views(pending.layout, pending.screen)
  end
  pending = nil
end

function M.restore_extra(_, data)
  local ok, decoded = pcall(vim.json.decode, data)
  if ok and type(decoded) == "table" then
    -- Wait for session replay and filetype hooks to finish before opening UI.
    vim.schedule(function()
      restore_trees(decoded.trees)
      restore_views(decoded.layout, decoded.screen)
    end)
  end
end

return M
