return {
  {
    "ghillb/cybu.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
    config = function()
      -- Ensure the plugins are loaded and configured with `lazy.nvim` or in your `init.lua`

      -- Install and configure cybu.nvim
      local ok, cybu = pcall(require, "cybu")
      if not ok then
        vim.notify("cybu.nvim not found", vim.log.levels.ERROR)
        return
      end

      -- Setup cybu.nvim with optional customization
      cybu.setup({
        position = {
          relative_to = "win",  -- Relative to the active window
          anchor = "topright",  -- Display in the top-right corner
          max_win_height = 10,  -- Limit the height of the popup
          max_win_width = 0.5,  -- Set width to half of the window
        },
        style = {
          border = "rounded",  -- Optional: rounded border for aesthetics
          hide_buffer_id = true, -- Hide buffer ID in popup
        },
        display_time = 700, -- Time (ms) the buffer list remains visible
        exclude = { "NvimTree", "TelescopePrompt" }, -- Ignore certain buffer types
      })
    end,
  },
}
