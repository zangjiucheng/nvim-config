# 💤 LazyVim

Jiucheng's personal [LazyVim](https://github.com/LazyVim/LazyVim) configuration, tuned to feel closer to a lightweight IDE without leaving normal Neovim workflows.

Refer to the [LazyVim documentation](https://lazyvim.github.io/installation) for base setup details.

## IDE-oriented workflow

- Fixed IDE-style panel layout: file explorer on the left, outline on the right, diagnostics/tasks/output at the bottom
- Outline sidebar via `aerial.nvim` for a VS Code-style structure pane
- Practical Python and JS/TS language support through LazyVim extras
- `neotest` workflow for Python, Jest, and Vitest
- Real DAP support with `nvim-dap`, `nvim-dap-ui`, `debugpy`, and `js-debug-adapter`
- Solid sidebars, floats, completion windows, and hover docs instead of a transparent/glass UI
- Autoformat enabled by default again, while still using LazyVim's formatter pipeline
- Task/build flow kept on top of the existing `compiler.nvim` + `overseer.nvim` stack

## Plugin layout

- `lua/plugins/ui.lua`: theme, cursor, mode/number accents
- `lua/plugins/navigation.lua`: motion helpers, outline/symbols, buffer cycling, LSP peek
- `lua/plugins/git.lua`: git signs and diff viewer
- `lua/plugins/workflow.lua`: sessions, projects, tasks, tests, debugging
- `lua/plugins/languages.lua`: Python and JS/TS language support, Jupytext, LaTeX via vimtex
- `lua/plugins/ai.lua`: Copilot core + chat UI

## Config layout

- `lua/config/options.lua`: globals, formatting, and UI defaults
- `lua/config/keymaps.lua`: top-level keymap grouping metadata
- `lua/config/autocmds.lua`: custom autocmds (colorcolumn highlight)

## Keymap design

The leader hierarchy is organized by workflow instead of plugin:

- `file/find`: files, explorer, search, terminals
- `code`: LSP actions, outline, refactors, diagnostics at point
- `run/task`: project task picker, build/dev tasks, task panel, file actions
- `test`: nearest/file test runs, debug test, summary, output
- `debug`: breakpoints, stepping, REPL, UI
- `project/session`: project switching and saved sessions
- `git`, `buffer`, `window`, and `diagnostics`: kept in their own predictable groups

There is also a small `gp` peek family for Glance-based definition/reference popups.

## Common keybindings

Most day-to-day usage fits into the following small set:

- Files and sidebars: `<leader>fe` file explorer, `<leader>be` buffer explorer, `<leader>ge` git explorer
- Navigation: `H` previous buffer, `L` next buffer, `s` Flash jump, `S` Treesitter jump
- Code and symbols: `<leader>cs` outline sidebar, `gpd` peek definition, `gpr` peek references, `gpi` peek implementation, `gpy` peek type definition
- Projects and sessions: `<leader>pp` switch project, `<leader>pr` restore session, `<leader>ps` save session, `<leader>pS` search sessions
- Run and tasks: `<leader>rr` run task, `<leader>rn` run project task, `<leader>rb` run build task, `<leader>rf` file run action, `<leader>ro` task panel
- Tests: `<leader>tr` run nearest test, `<leader>tt` run file tests, `<leader>td` debug nearest test, `<leader>ts` test summary, `<leader>to` test output
- Debugging: `<leader>db` toggle breakpoint, `<leader>dc` continue, `<leader>di` step into, `<leader>dO` step over, `<leader>do` step out, `<leader>du` toggle dap-ui
- AI: `<leader>aa` toggle Copilot sidebar, `<leader>ao` open Copilot sidebar, `<leader>ac` clear chat, `<leader>ae` explain code, `<leader>ar` review code, `<leader>af` fix code, `<leader>at` generate tests

Inside the left `git` explorer, `<CR>` opens the selected file in `Diffview`, while `o` still opens the file normally.

## Project defaults

- Python defaults to `pytest`, prefers `.venv`/`venv` interpreters when available, and uses `.env` for debug/task execution
- Node/TS projects automatically lean toward either Vitest or Jest instead of trying both equally
- `dap.continue()` will pick up `.vscode/launch.json` automatically when present, so project launch configs stay first-class
- Overseer now includes lightweight project templates for common Python and Node workflows, while still surfacing built-in providers like `npm`, `task`, `make`, and `.vscode/tasks.json`

## External tools

Neovim can install most editor-side components through Mason, but the runtime tools still need to exist in the project or environment:

- Python: `pytest` for tests, plus a Python interpreter/virtualenv for the project
- JavaScript/TypeScript: `jest` and/or `vitest` in the workspace for neotest adapters
- Debugging: Mason-managed `debugpy` and `js-debug-adapter`, plus `tsx` or `ts-node` if you want to launch TypeScript files directly
