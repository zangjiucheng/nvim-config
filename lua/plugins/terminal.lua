return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<c-\>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
      hide_numbers = true, -- hide the number column in toggleterm buffers
      shade_filetypes = {},
      autochdir = false, -- when neovim changes its current directory the terminal will change its own when next it's opened
      highlights = {
        Normal = {
          guibg = "NONE",
        },
        NormalFloat = {
          link = 'Normal'
        },
        FloatBorder = {
          guifg = "#ffffff",
          guibg = "#000000",
        },
      },
      shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
      shading_factor = 2, -- the percentage by which to lighten dark terminal background, default: -30
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      persist_size = true,
      direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
      close_on_exit = true, -- close the terminal window when the process exits
      shell = vim.o.shell, -- Change the default shell. Can be a string or a function returning a string
      auto_scroll = true, -- automatically scroll to the bottom on terminal output
      float_opts = {
        border = 'double', -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
        width = 100,
        height = 30,
        winblend = 10,
      },
    }
  },
}
