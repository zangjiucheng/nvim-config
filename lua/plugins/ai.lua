local function copilot_chat_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "copilot-chat" then
      return win, buf
    end
  end
end

local function place_copilot_sidebar()
  local win = copilot_chat_window()
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local current = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)
  vim.cmd("wincmd L")
  vim.api.nvim_win_set_width(win, 46)

  vim.wo[win].winfixwidth = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].statuscolumn = ""
  vim.wo[win].foldcolumn = "1"
  vim.wo[win].winhighlight =
    "Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC,FloatBorder:FloatBorder,WinSeparator:FloatBorder"

  if vim.api.nvim_win_is_valid(current) and current ~= win then
    vim.api.nvim_set_current_win(current)
  end
end

local function toggle_copilot_sidebar()
  require("CopilotChat").toggle()
  vim.schedule(place_copilot_sidebar)
end

local function open_copilot_sidebar()
  require("CopilotChat").open()
  vim.schedule(place_copilot_sidebar)
end

local function ask_copilot(prompt)
  return function()
    require("CopilotChat").open()
    vim.schedule(function()
      place_copilot_sidebar()
      require("CopilotChat").ask(prompt)
    end)
  end
end

local function leave_insert_and_wincmd(dir)
  return function()
    if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
      vim.cmd.stopinsert()
    end
    vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      debug = false,
      auto_insert_mode = true,
      window = {
        layout = "vertical",
        width = 46,
      },
      mappings = {
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
      },
    },
    keys = {
      { "<leader>aa", toggle_copilot_sidebar, desc = "Toggle AI Sidebar" },
      { "<leader>ao", open_copilot_sidebar, desc = "Open AI Sidebar" },
      { "<leader>ac", "<cmd>CopilotChatReset<cr>", desc = "Clear AI Chat" },
      { "<leader>ae", ask_copilot("Explain this code"), desc = "Explain Code", mode = { "n", "v" } },
      { "<leader>ar", ask_copilot("Review this code"), desc = "Review Code", mode = { "n", "v" } },
      { "<leader>af", ask_copilot("Fix this code"), desc = "Fix Code", mode = { "n", "v" } },
      { "<leader>at", ask_copilot("Generate tests for this code"), desc = "Generate Tests", mode = { "n", "v" } },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      local group = vim.api.nvim_create_augroup("IDECopilotSidebar", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "copilot-chat",
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("i", "<Esc><Esc>", "<Esc>", opts)
          vim.keymap.set({ "i", "n" }, "<C-h>", leave_insert_and_wincmd("h"), opts)
          vim.keymap.set({ "i", "n" }, "<C-j>", leave_insert_and_wincmd("j"), opts)
          vim.keymap.set({ "i", "n" }, "<C-k>", leave_insert_and_wincmd("k"), opts)
          vim.keymap.set({ "i", "n" }, "<C-l>", leave_insert_and_wincmd("l"), opts)
          vim.schedule(place_copilot_sidebar)
        end,
      })
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp",
    },
    cmd = "Copilot",
    event = "InsertEnter",
    init = function()
      vim.g.copilot_nes_debounce = 500
    end,
    opts = {
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = "<leader>p",
          accept = false,
          dismiss = "<Esc>",
        },
      },
    },
  },
}
