-- Jupyter notebooks.
--
-- Three pieces, each with one job:
--   * jupytext.nvim converts .ipynb <-> percent-format Python on open/save, so
--     the file you edit is ordinary Python with `# %%` cell markers.
--   * molten-nvim runs cells against a real Jupyter kernel and owns the output.
--   * image.nvim draws plots inline.
--
-- The kernel is NOT vim.g.python3_host_prog (see lua/config/options.lua) — that
-- interpreter only carries molten's RPC. Notebooks run on whichever kernel you
-- pick at :MoltenInit, so a project venv needs to register itself once:
--   <project-venv>/bin/python -m ipykernel install --user --name <project>
-- Filetypes that can hold notebook cells.
local nb_filetypes = { "python", "quarto", "markdown" }

-- jupytext hands us percent-format Python: cells delimited by `# %%` lines.
-- Molten has no concept of those, so locate the current cell and give it a
-- visual selection.
local function cell_bounds()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local total = vim.api.nvim_buf_line_count(0)
  local function is_marker(lnum)
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    return line ~= nil and line:match("^%s*#%s*%%%%") ~= nil
  end

  local first = cur
  while first > 1 and not is_marker(first) do
    first = first - 1
  end
  if is_marker(first) then
    first = first + 1
  end

  local last = cur
  while last < total and not is_marker(last + 1) do
    last = last + 1
  end
  return first, last
end

local function run_cell()
  local first, last = cell_bounds()
  if first > last then
    vim.notify("Empty cell", vim.log.levels.INFO)
    return
  end
  -- MoltenEvaluateVisual reads the '< and '> marks, which Vim only writes when
  -- you *leave* visual mode. Setting them directly avoids entering visual mode
  -- at all, which would otherwise leave the cursor and mode in a weird state.
  local last_line = vim.api.nvim_buf_get_lines(0, last - 1, last, false)[1] or ""
  vim.api.nvim_buf_set_mark(0, "<", first, 0, {})
  vim.api.nvim_buf_set_mark(0, ">", last, math.max(#last_line - 1, 0), {})
  vim.cmd("noautocmd MoltenEvaluateVisual")
end

local molten_maps = {
  { "mi", "<cmd>MoltenInit<cr>", "Init Kernel" },
  { "mc", run_cell, "Run Cell" },
  { "ml", "<cmd>MoltenEvaluateLine<cr>", "Run Line" },
  { "mr", "<cmd>MoltenReevaluateCell<cr>", "Re-run Cell" },
  { "mR", "<cmd>MoltenReevaluateAll<cr>", "Re-run All" },
  { "mo", "<cmd>MoltenShowOutput<cr>", "Show Output" },
  { "mh", "<cmd>MoltenHideOutput<cr>", "Hide Output" },
  { "mE", "<cmd>MoltenEnterOutput<cr>", "Enter Output Window" },
  { "mn", "<cmd>MoltenNext<cr>", "Next Cell Output" },
  { "mp", "<cmd>MoltenPrev<cr>", "Previous Cell Output" },
  { "mx", "<cmd>MoltenInterrupt<cr>", "Interrupt Kernel" },
  { "mK", "<cmd>MoltenRestart!<cr>", "Restart Kernel" },
  { "md", "<cmd>MoltenDelete<cr>", "Delete Cell Output" },
  { "mb", "<cmd>MoltenOpenInBrowser<cr>", "Open Output in Browser" },
  { "ms", "<cmd>MoltenSave<cr>", "Save Outputs" },
  { "mL", "<cmd>MoltenLoad<cr>", "Load Saved Outputs" },
}

local function attach_molten_keymaps(buf)
  for _, m in ipairs(molten_maps) do
    vim.keymap.set("n", "<leader>" .. m[1], m[2], { buffer = buf, desc = m[3] })
  end
  vim.keymap.set("x", "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>gv<esc>", {
    buffer = buf,
    desc = "Run Selection",
  })

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({ { "<leader>m", group = "molten/notebook", buffer = buf } })
  end
end

return {
  {
    "GCBallesteros/jupytext.nvim",
    -- Not lazy-loadable: it works through a BufReadCmd, which has to be
    -- registered before the read starts. Loading on BufReadPre is already too
    -- late and the notebook opens as raw JSON.
    lazy = false,
    opts = {
      style = "percent",
      output_extension = "py",
      force_ft = "python",
      custom_language_formatting = {
        python = {
          extension = "py",
          style = "percent",
          force_ft = "python",
        },
      },
    },
  },

  {
    "3rd/image.nvim",
    -- 10ms at startup, 6.5 of it shelling out to tmux to probe state. Nothing
    -- needs it until a notebook (or markdown image) is open.
    ft = nb_filetypes,
    opts = {
      backend = "kitty", -- Ghostty speaks the kitty graphics protocol
      -- The CLI processor shells out to ImageMagick. The default "magick_rock"
      -- needs a luarocks build, and `:checkhealth lazy` reports luarocks is
      -- unavailable here.
      processor = "magick_cli",
      max_width_window_percentage = 45,
      -- Inside tmux, only paint images in the focused window, and repaint when
      -- a float covers them; otherwise stale plots smear across panes.
      tmux_show_only_in_active_window = true,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "blink-cmp-menu" },
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    -- Safe to defer: the Molten* commands come from the remote-plugin manifest
    -- (rplugin.vim, sourced at startup), and `init` below still runs eagerly so
    -- the g:molten_* options are set before the plugin ever initialises.
    ft = nb_filetypes,
    -- Registers the remote plugin; without it the Molten* commands never exist.
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      -- Output as virtual lines under the cell rather than a float that steals
      -- the screen; the float is still one keystroke away on <leader>mo.
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_output_crop_border = true

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("MoltenKeymaps", { clear = true }),
        pattern = nb_filetypes,
        callback = function(args)
          attach_molten_keymaps(args.buf)
        end,
      })
    end,
  },
}
