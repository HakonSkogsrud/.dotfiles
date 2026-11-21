" Detect filetypes and load their editing and indentation rules.
filetype plugin indent on
syntax enable

" Insert spaces for Tab, and use four spaces per indent.
set expandtab shiftwidth=4 softtabstop=-1
" Display existing tab characters as four columns wide.
set tabstop=4
set ruler showmatch
set autoread

augroup simple_filetypes
  autocmd!
  " Recognize common Ansible paths. For other playbooks use :set ft=yaml.ansible.
  autocmd BufRead,BufNewFile */playbooks/*.yml,*/playbooks/*.yaml,*/roles/*/tasks/*.yml,*/roles/*/handlers/*.yml,*/roles/*/tasks/*.yaml,*/roles/*/handlers/*.yaml setlocal filetype=yaml.ansible
  " A dotted filetype loads both the target format and Jinja syntax.
  autocmd BufRead,BufNewFile *.yml.j2,*.yaml.j2 setlocal filetype=yaml.jinja
  autocmd BufRead,BufNewFile *.sh.j2 setlocal filetype=sh.jinja
  autocmd BufRead,BufNewFile *.service.j2,*.timer.j2 setlocal filetype=systemd.jinja
  autocmd BufRead,BufNewFile *.ini.j2 setlocal filetype=dosini.jinja
  autocmd BufRead,BufNewFile *.conf.j2,.env.j2 setlocal filetype=conf.jinja
  autocmd BufRead,BufNewFile *.j2 if &l:filetype !~# 'jinja$' | setlocal filetype=jinja | endif
  autocmd FileType yaml,yaml.ansible,yaml.jinja setlocal shiftwidth=2
augroup END

if has('nvim-0.12')
lua << EOF
-- Each server command runs the executable from PATH.
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
})
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyrightconfig.json', 'pyproject.toml', '.git' },
})
vim.lsp.config('ansiblels', {
  cmd = { 'ansible-language-server', '--stdio' },
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint', '.git' },
})

-- Enable servers whose executables are installed.
for _, name in ipairs({ 'clangd', 'pyright', 'ansiblels' }) do
  if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end
EOF
endif
