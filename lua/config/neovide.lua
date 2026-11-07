-- lua/config/neovide.lua
-- Neovide GUI settings, required from options.lua; a no-op in a terminal.
-- The same file lives in nix-config (Linux, via home-manager) and
-- ~/nvim-config (macOS) -- keep the two copies identical.
--
-- Only non-default values are set. Neovide already defaults to
-- scale_factor = 1.0, opacity = 1.0, remember_window_size = true,
-- no_idle = false, so those are left out.
if not vim.g.neovide then
  return
end

local g = vim.g
local map = vim.keymap.set
local is_mac = vim.fn.has("mac") == 1

--- Font ---------------------------------------------------------------------
-- macOS: JetBrains Mono (installed by nix-darwin) + Nerd Font symbols fallback.
-- Linux: Maple Mono NF CN is the fontconfig monospace default (Nerd glyphs +
--        CJK); size 11 roughly matches Ghostty's font-size = 10.
vim.o.guifont = is_mac and "JetBrains Mono,Symbols Nerd Font Mono:h14"
  or "Maple Mono NF CN,Iosevka Nerd Font:h11"
vim.o.linespace = 0
g.neovide_padding_top = 4
g.neovide_padding_left = 4
g.neovide_padding_right = 4

--- No animations: windows, scrolling and cursor move instantly --------------
g.neovide_position_animation_length = 0
g.neovide_scroll_animation_length = 0
g.neovide_scroll_animation_far_lines = 0
g.neovide_cursor_animation_length = 0
g.neovide_cursor_short_animation_length = 0
g.neovide_cursor_trail_size = 0
g.neovide_cursor_vfx_mode = ""

--- Behaviour ----------------------------------------------------------------
g.neovide_hide_mouse_when_typing = true
if is_mac then
  -- Left Option acts as Meta so <M-...> mappings work; right Option still
  -- types special characters.
  g.neovide_input_macos_option_key_is_meta = "only_left"
end

--- IME: enabled only in insert mode and / ? search, so a Chinese input
--- method doesn't swallow normal-mode keys.
local function set_ime(on)
  return function()
    g.neovide_input_ime = on
  end
end
local ime = vim.api.nvim_create_augroup("neovide_ime", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", { group = ime, callback = set_ime(true) })
vim.api.nvim_create_autocmd("InsertLeave", { group = ime, callback = set_ime(false) })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = ime, pattern = { "/", "?" }, callback = set_ime(true) })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = ime, pattern = { "/", "?" }, callback = set_ime(false) })
g.neovide_input_ime = false

--- Zoom: <Mod>= / <Mod>- / <Mod>0 (Cmd on macOS, Ctrl on Linux) -------------
local mod = is_mac and "D" or "C"
local function zoom(factor)
  return function()
    g.neovide_scale_factor = factor and g.neovide_scale_factor * factor or 1.0
  end
end
map({ "n", "v" }, ("<%s-=>"):format(mod), zoom(1.1), { desc = "Neovide zoom in" })
map({ "n", "v" }, ("<%s-->"):format(mod), zoom(1 / 1.1), { desc = "Neovide zoom out" })
map({ "n", "v" }, ("<%s-0>"):format(mod), zoom(nil), { desc = "Neovide reset zoom" })

--- System clipboard: Cmd+C/V on macOS, Ctrl+Shift+C/V on Linux --------------
-- (there is no terminal emulator around to handle these for us)
local copy = is_mac and "<D-c>" or "<C-S-c>"
local paste = is_mac and "<D-v>" or "<C-S-v>"
map("v", copy, '"+y', { desc = "Copy to system clipboard" })
map({ "n", "v" }, paste, '"+P', { desc = "Paste from system clipboard" })
map({ "i", "c" }, paste, "<C-r>+", { desc = "Paste from system clipboard" })
map("t", paste, [[<C-\><C-n>"+pi]], { desc = "Paste from system clipboard" })
