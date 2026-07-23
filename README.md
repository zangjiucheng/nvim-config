# nvim-config

Jiucheng's personal [LazyVim](https://github.com/LazyVim/LazyVim) configuration, tuned into a VS Code-shaped daily driver — command palette, debugger, source control, minimap — without ever giving up core Vim motions.

**[📖 Full usage guide →](https://zangjiucheng.github.io/nvim-config/)** — install steps, the complete keymap reference, and architecture live there. This README is the short version.

[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-informational)](./LICENSE)

## Quick install

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
git clone https://github.com/zangjiucheng/nvim-config.git ~/.config/nvim
nvim
```

First launch bootstraps `lazy.nvim`, installs every plugin, and pulls LSP servers/formatters/debug adapters through Mason — let it finish, then restart once. Needs a [Nerd Font](https://www.nerdfonts.com/) for icons to render correctly. Full requirements: see the [usage guide](https://zangjiucheng.github.io/nvim-config/#requirements).

## What this is

- Fixed IDE-style layout: file explorer left, outline right, diagnostics/tasks/output along the bottom
- VS Code-style breadcrumbs (`dropbar.nvim`), sticky scroll (`treesitter-context`), and a code minimap (`neominimap.nvim`)
- Full Git source-control panel via `neogit`, integrated with Diffview and inline `gitsigns` blame
- Command palette and a `Ctrl+Shift+*` shortcut family, deliberately chosen to never shadow a core Vim motion
- Real debugging (`nvim-dap` + `nvim-dap-ui`) and testing (`neotest`) for Python and JS/TS, picking up `.vscode/launch.json` when present
- Practical Python, TypeScript/JS, Vue, Nix, and LaTeX support through LazyVim's extras system
- Lightweight, dependency-free remote SSH and multi-root-tab workflows (`<leader>pR`, `<leader>pt`)

## Layout

```
lua/config/   options, keymaps, autocmds, project/venv detection helpers
lua/plugins/  ui · navigation · editor · git · workflow · languages · ai · other
```

Each file's scope is documented in the [Architecture](https://zangjiucheng.github.io/nvim-config/#architecture) section of the usage guide, along with the full keymap tables.

## License

[Apache-2.0](./LICENSE)
