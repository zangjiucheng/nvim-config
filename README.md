# 💤 LazyVim

Jiucheng's personal [LazyVim](https://github.com/LazyVim/LazyVim) configuration, tuned to feel closer to a lightweight IDE without leaving normal Neovim workflows.

Refer to the [LazyVim documentation](https://lazyvim.github.io/installation) for base setup details.

## IDE-oriented workflow

- Fixed IDE-style panel layout: file explorer on the left, outline on the right, diagnostics/tasks/output at the bottom
- Outline sidebar via `aerial.nvim` for a VS Code-style structure pane
- VS Code-style breadcrumbs (`dropbar.nvim`) and sticky scroll (`treesitter-context`)
- Code overview minimap with git/diagnostic markers via `neominimap.nvim`
- Full Git source-control panel via `neogit` (staging, commit, log, integrated with Diffview)
- Inline color swatches (`nvim-highlight-colors`), smooth scrolling (`snacks.scroll`), and LSP-aware folding (`nvim-ufo`)
- Command palette and a unified set of VS Code-style shortcuts that avoid clobbering core Vim motions
- Practical Python and JS/TS language support through LazyVim extras
- `neotest` workflow for Python, Jest, and Vitest
- Real DAP support with `nvim-dap`, `nvim-dap-ui`, `debugpy`, and `js-debug-adapter`
- Solid sidebars, floats, completion windows, and hover docs instead of a transparent/glass UI
- Autoformat enabled by default again, while still using LazyVim's formatter pipeline
- Task/build flow kept on top of the existing `compiler.nvim` + `overseer.nvim` stack

## Plugin layout

- `lua/plugins/ui.lua`: theme, cursor, mode/number accents, breadcrumbs, sticky scroll, color swatches, smooth scroll, minimap
- `lua/plugins/navigation.lua`: motion helpers, outline/symbols, buffer cycling, LSP peek
- `lua/plugins/editor.lua`: LSP/treesitter folding
- `lua/plugins/git.lua`: git signs, diff viewer, and the Neogit source-control panel
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
- Projects and sessions: `<leader>pp` switch project, `<leader>pr` restore session, `<leader>ps` save session, `<leader>pS` search sessions, `<leader>pt` new project tab (multi-root), `<leader>pR` remote SSH session
- Run and tasks: `<leader>rr` run task, `<leader>rn` run project task, `<leader>rb` run build task, `<leader>rf` file run action, `<leader>ro` task panel
- Tests: `<leader>tr` run nearest test, `<leader>tt` run file tests, `<leader>td` debug nearest test, `<leader>ts` test summary, `<leader>to` test output
- Debugging: `<leader>db` toggle breakpoint, `<leader>dc` continue, `<leader>di` step into, `<leader>dO` step over, `<leader>do` step out, `<leader>du` toggle dap-ui
- AI: `<leader>aa` toggle Copilot sidebar, `<leader>ao` open Copilot sidebar, `<leader>ac` clear chat, `<leader>ae` explain code, `<leader>ar` review code, `<leader>af` fix code, `<leader>at` generate tests

Inside the left `git` explorer, `<CR>` opens the selected file in `Diffview`, while `o` still opens the file normally.

## VS Code-style shortcuts

These mirror common VS Code muscle memory and are deliberately chosen **not** to clobber core Vim motions (so `Ctrl+D`/`Ctrl+U` half-page scroll, etc. keep working). Most live in `lua/config/keymaps.lua`, a few in the relevant plugin specs.

Panels and pickers — the unified `Ctrl+Shift+*` family:

- `Ctrl+Shift+P` / `<leader>P` command palette
- `Ctrl+Shift+F` search in files
- `Ctrl+Shift+E` toggle file explorer
- `Ctrl+Shift+G` source-control panel (`neogit`, also `<leader>gn`)
- `Ctrl+Shift+O` go to symbol in file

Editing and navigation:

- `Alt+S` save file (works in normal/insert/visual; added because the tmux prefix here is `Ctrl+S`, which swallows LazyVim's default `<C-s>` save)
- `Ctrl+P` quick open file
- `F2` rename symbol, `F12` go to definition
- `Alt+Up` / `Alt+Down` move the current line (aliases of LazyVim's `Alt+j`/`Alt+k`)
- `zR` / `zM` open/close all folds, `zK` peek the folded lines (or hover when not on a fold)

View toggles (`<leader>U` group):

- `<leader>Us` sticky scroll, `<leader>Uc` color swatches, `<leader>Um` minimap
- `<leader>cb` jump through breadcrumb components

The `Ctrl+Shift+*` bindings need a terminal that forwards those combinations (kitty, WezTerm, Ghostty, …); the `<leader>` equivalents always work as fallbacks. `Ctrl+P` is the only binding that shadows a default motion (line-up, redundant with `k`) — remove that line in `keymaps.lua` if you want it back.

## Remote development & multi-root

No dedicated plugins for either — both lean on plain Neovim primitives to stay dependency-free:

- **Remote development**: `<leader>pR` prompts for a host and opens `ssh <host>` in a floating terminal, running your remote box's own Neovim (not a local-UI-driving-remote-backend setup like VS Code Remote-SSH). Pair with `tmux` on the remote side to keep sessions alive across disconnects.
- **Multi-root workspaces**: `<leader>pt` opens a new tab, lets you pick from `project.nvim`'s recent-projects list, and runs `:tcd` scoped to that tab plus opens the explorer there. Each tab is effectively its own workspace root — switch tabs (`gt`/`gT`) to switch "workspace". `<leader>pp` still does a single-window project switch when you don't need a separate tab.

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
