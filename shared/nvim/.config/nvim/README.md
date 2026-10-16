# Neovim configuration

Personal Neovim configuration based on [LazyVim](https://www.lazyvim.org/).

The configuration enables LazyVim's Python, Ansible, and Terraform extras, adds
Jinja file type detection, and uses the VS Code-inspired color scheme from
`vscode.nvim`. The Terraform extra provides `terraformls`, Terraform/HCL syntax
parsers, `terraform fmt`, validation, and `tflint`.

Plugin versions are recorded in `lazy-lock.json`. Update plugins from Neovim
with `:Lazy update`, then commit the resulting lockfile changes.
