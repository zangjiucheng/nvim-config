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
    branch = "main",
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
      -- VS Code-style inline suggestions: ghost text appears while you type,
      -- and can be taken a word at a time instead of all-or-nothing.
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- Never draw ghost text underneath an open blink.cmp menu.
        hide_during_completion = true,
        -- The plugin default is 15ms, which fires a request at almost every
        -- keystroke. 100ms still feels instant while typing fast maths.
        debounce = 100,
        keymap = {
          -- Accepting the whole suggestion goes through <Tab>
          -- (LazyVim.cmp.actions.ai_accept, wired in config below) and <M-l>.
          accept = "<M-l>",
          -- VS Code's Cmd+Right (editor.action.inlineSuggest.acceptNextWord).
          -- Alt+Right is the version a terminal can actually deliver.
          accept_word = "<M-Right>",
          -- Ctrl+Shift+* needs a terminal that forwards it (ghostty/kitty/
          -- wezterm), matching the convention in lua/config/keymaps.lua.
          accept_line = "<C-S-Right>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
          -- Panic switch when ghost text gets in the way mid-paragraph.
          toggle_auto_trigger = "<M-\\>",
        },
      },
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = "<leader>p",
          accept = false,
          dismiss = "<Esc>",
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      -- LazyVim's <Tab> chain is snippet_forward -> ai_nes -> ai_accept.
      -- Without the ai.copilot extra nothing defines ai_accept, so <Tab> did
      -- not accept suggestions at all. Snippet jumps still win over it.
      LazyVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
    keys = {
      -- Alias for terminals that swallow Alt+Right (it falls through to the
      -- normal key when no suggestion is showing).
      {
        "<C-Right>",
        function()
          require("copilot.suggestion").accept_word()
        end,
        mode = "i",
        desc = "Accept AI Suggestion (word)",
      },
    },
  },

  -- Inline AI assistant: VS Code's Cmd+I. Ask in place, it edits the buffer.
  --
  -- Separate from CopilotChat above on purpose: CopilotChat is Copilot-only and
  -- answers in a sidebar, this one writes into the buffer and can talk to any
  -- provider. Pure Lua, no build step, and both dependencies are already here.
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    opts = function()
      -- Use DeepSeek when its key is exported, otherwise fall back to the
      -- Copilot session that is already authenticated. Export DEEPSEEK_API_KEY
      -- (or swap the string) to switch provider; `:CodeCompanionChat openai`
      -- and friends still work per-invocation.
      local adapter = (vim.env.DEEPSEEK_API_KEY or "") ~= "" and "deepseek" or "copilot"
      return {
        -- Note: the top-level key is `interactions`, not the `strategies`
        -- used by older releases and most blog posts; unknown keys are
        -- dropped silently, so the wrong one looks like it works.
        interactions = {
          inline = { adapter = adapter },
          chat = { adapter = adapter },
        },
        display = {
          -- Only used when the inline assistant has to create a new buffer;
          -- edits to the current buffer happen in place.
          inline = { layout = "vertical" },
        },
        opts = { log_level = "ERROR" },
      }
    end,
    keys = {
      -- Alt+I is what a terminal can actually deliver. See the README note on
      -- forwarding literal Cmd+I from ghostty.
      { "<M-i>", "<cmd>CodeCompanion<cr>", mode = "n", desc = "Inline AI (ask)" },
      { "<M-i>", ":CodeCompanion<cr>", mode = "x", desc = "Inline AI (rewrite selection)" },
      { "<M-i>", "<esc><cmd>CodeCompanion<cr>", mode = "i", desc = "Inline AI (ask)" },
      {
        "<leader>ai",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "Toggle AI Chat (multi-provider)",
      },
      { "<leader>aA", "<cmd>CodeCompanionActions<cr>", mode = { "n", "x" }, desc = "AI Action Palette" },
    },
  },
}
