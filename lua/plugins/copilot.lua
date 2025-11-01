return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = false, -- Enable debugging
    },
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
