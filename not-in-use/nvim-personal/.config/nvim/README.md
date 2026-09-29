# Personal Neovim config

This is the archived standalone `lazy.nvim` config. It is not the active
`~/.config/nvim` setup.

It targets Neovim 0.12+. Mason installs the Python and Ansible language
servers, plus `ansible-lint` and the configured formatters. Python uses
basedpyright, Ruff, Ruff formatting, and `uv run pytest` for tests.
Ansible files use `yaml.ansible`, ansible-language-server, and ansible-lint.
Playbook execution still needs `ansible` available in the project environment
or on `PATH`.

The GitHub theme's `transparent = true` option provides a transparent
background without a separate transparency plugin. Neo-tree remains the
file explorer, without its Git status integration.

Existing shortcuts use LazyVim's keys where an equivalent is available
(for example `<leader>ff`, `<leader>sR`, `<leader>cd`, `gd`, and `gr`).
The terminal still opens a split on `<C-/>`, not LazyVim's floating terminal.
Visual `p`, `jk` to exit insert/terminal mode, and `<leader>ta` for pytest
remain personal shortcuts without LazyVim equivalents.

Tree-sitter needs its CLI. Mason installs it, and parser installation starts
on the next Neovim launch if the CLI was not yet available on the first one.
The existing lockfile records the old plugin revisions. Run `:Lazy update`
and commit the refreshed lockfile before adopting this config.
