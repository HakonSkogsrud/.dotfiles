-- 1. SETTINGS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)
vim.o.shell = "fish"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Use 2 spaces for indent (common for Lua/YAML)
vim.opt.tabstop = 4 -- A tab character looks like 2 spaces
vim.opt.softtabstop = 4 -- Number of spaces a tab counts for while editing

vim.filetype.add({
    extension = {
        yml = function(path)
            if path:match("playbook") or path:match("tasks") or path:match("roles") then
                return "yaml.ansible"
            end
            return "yaml"
        end,
        yaml = function(path)
            if path:match("playbook") or path:match("tasks") or path:match("roles") then
                return "yaml.ansible"
            end
            return "yaml"
        end,
    },
    pattern = {
        [".*%.sh%.j2"] = "sh",
        [".*%.bash%.j2"] = "sh",
    },
})
-- 2. LAZY.NVIM BOOTSTRAP
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

-- 3. PLUGINS
require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight")
        end,
    },
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
        opts = {},
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            local caps = require("blink.cmp").get_lsp_capabilities()
            local lspconfig = require("lspconfig")

            local servers = {
                basedpyright = { settings = { basedpyright = { analysis = { typeCheckingMode = "basic" } } } },
                gopls = {},
                ansiblels = {},
                ruff = {},
                lua_ls = {},
            }

            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, caps, server.capabilities or {})
                        lspconfig[server_name].setup(server)
                    end,
                },
            })
        end,
    },

    -- Autocomplete
    {
        "saghen/blink.cmp",
        version = "v0.*",
        opts = {
            keymap = {
                preset = "none",
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<Esc>"] = { "hide", "fallback" },
            },
        },
    },
    -- Formatting (Best for Go and Python)
    {
        "stevearc/conform.nvim",
        opts = {
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_format" },
                go = { "goimports", "gofmt" },
            },
        },
    },

    -- Debugging
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
            "leoluz/nvim-dap-go",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            require("dap-python").setup("python3")
            require("dap-go").setup()
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = { "python", "go", "ansible", "yaml", "lua", "bash", "markdown" },
            })
            -- Enable treesitter-based indentation (v1.0.0+ uses native vim option)
            vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    },
})

-- 4. KEYMAPS

-- Standard window movement
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Terminal-mode movement (Jump out of terminal seamlessly)
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- Terminal Toggle Logic
local term_buf = nil
local term_win = nil

function _G.toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
    else
        vim.cmd("botright split")
        vim.api.nvim_win_set_height(0, 15)
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_set_current_buf(term_buf)
        else
            vim.cmd("term")
            term_buf = vim.api.nvim_get_current_buf()
        end
        term_win = vim.api.nvim_get_current_win()
        vim.cmd("startinsert")
    end
end

-- 1. Map for Normal Mode
vim.keymap.set("n", "<leader>tt", "<cmd>lua toggle_terminal()<CR>", { desc = "Toggle Terminal" })

-- 2. Map for Terminal Mode (Allows toggling OFF while typing in Fish)
vim.keymap.set("t", "<leader>tt", [[<C-\><C-n><cmd>lua toggle_terminal()<CR>]], { desc = "Toggle Terminal" })
-- Telescope Search Suite
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search Resume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search Recent Files" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search buffer" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Terminal and Explorer
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<C-Up>", ":resize +4<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -4<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -4<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +4<CR>")
-- LSP Attach Mappings
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local buf = event.buf
        vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "Goto References" })
        vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "Goto Definition" })
        vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename" })
        vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Action" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "Hover Documentation" })
    end,
})
-- Automatically enter Insert Mode when entering a terminal buffer
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermOpen" }, {
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
    end,
})
-- go
vim.keymap.set("n", "<leader>ta", "<cmd>!go test ./...<CR>", { desc = "Run All Tests" })
-- Debugging
local dap = require("dap")
vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)

-- 5. TRANSPARENCY
local function set_transparent()
    local groups = { "Normal", "NormalFloat", "NormalNC", "SignColumn", "NeoTreeNormal", "NeoTreeNormalNC" }
    for _, hl in ipairs(groups) do
        vim.api.nvim_set_hl(0, hl, { bg = "none" })
    end
end
set_transparent()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent })
