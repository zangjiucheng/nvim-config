-- Snippet engine. LuaSnip comes from LazyVim's `coding.luasnip` extra, which
-- also flips blink.cmp's snippet preset to "luasnip" — so <Tab>/<S-Tab> keep
-- using LazyVim's existing mappings, nothing new is bound for navigation.
return {
  {
    "L3MON4D3/LuaSnip",
    -- Load with the first insert (blink.cmp would pull it in anyway); this just
    -- guarantees the autosnippet autocmds exist before the first keystroke.
    event = "InsertEnter",
    opts = {
      -- `;a` -> \alpha and friends expand without pressing anything.
      enable_autosnippets = true,
      -- Leaving a snippet's region should end it, otherwise stale jump points
      -- accumulate during a long writing session.
      region_check_events = "CursorMoved,InsertLeave",
      delete_check_events = "TextChanged,InsertLeave",
    },
    config = function(_, opts)
      local luasnip = require("luasnip")
      luasnip.setup(opts)
      -- friendly-snippets (vscode format) is loaded by the LazyVim extra; this
      -- adds the hand-written Lua snippets in lua/snippets/<filetype>.lua.
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      })

      -- Cycles the optional-argument choice inside structural snippets, e.g.
      -- the [name] of a theorem. Each choice node here has two options, so
      -- pressing it again cycles back.
      --
      -- Set here rather than via lazy's `keys`: lazy only materialises a `keys`
      -- mapping when that key is what triggered the load, and this plugin is
      -- loaded by its `event`. Declared there, the mapping silently never
      -- exists. <C-l> is free in insert/select mode; LazyVim only uses it for
      -- window navigation in normal and terminal mode.
      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, { desc = "Cycle Snippet Choice" })
    end,
  },

  -- LazyVim's <Tab> chain is snippet_forward -> ai_nes -> ai_accept -> fallback:
  -- it jumps *within* an already-active snippet but never expands a trigger, so
  -- typing `cases<Tab>` just inserted a literal tab and the completion menu was
  -- the only way to expand anything. Put expansion at the front of the chain.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<Tab>"] = {
        function()
          local ls = require("luasnip")
          if ls.expandable() then
            -- blink runs keymap commands under textlock, so the edit has to be
            -- deferred; claim the key synchronously so the chain stops here.
            vim.schedule(function()
              ls.expand()
            end)
            return true
          end
        end,
        LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
        "fallback",
      }
    end,
  },
}
