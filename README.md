# 💤 LazyVim

Jiucheng's Personal LazyVim Configuration modify from [LazyVim](https://github.com/LazyVim/LazyVim) template.

Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Plugin layout

- `lua/plugins/ui.lua`: theme, cursor, mode/number accents
- `lua/plugins/navigation.lua`: motion helpers, buffer cycling, LSP peek
- `lua/plugins/git.lua`: git signs and diff viewer
- `lua/plugins/workflow.lua`: sessions, projects, task runner/compilation
- `lua/plugins/languages.lua`: Python venv + Jupytext, LaTeX via vimtex
- `lua/plugins/ai.lua`: Copilot core + chat UI

## Config layout

- `lua/config/options.lua`: globals and UI options
- `lua/config/keymaps.lua`: extra mappings grouped by feature
- `lua/config/autocmds.lua`: custom autocmds (colorcolumn highlight)
