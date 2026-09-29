-- 1. SETTINGS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.shell = "zsh"
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

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Use four spaces for indentation
vim.opt.tabstop = 4 -- Display a tab as four spaces
vim.opt.softtabstop = 4 -- Number of spaces a tab counts for while editing

local function yaml_filetype(path)
	local normalized_path = path:lower()
	if
		normalized_path:match("playbook")
		or normalized_path:match("site%.ya?ml$")
		or normalized_path:match("/roles?/")
		or normalized_path:match("/tasks?/")
		or normalized_path:match("/(group_vars|host_vars)/")
	then
		return "yaml.ansible"
	end
	return "yaml"
end

vim.filetype.add({
	extension = {
		yml = yaml_filetype,
		yaml = yaml_filetype,
	},
	pattern = {
		[".*%.sh%.j2"] = "sh",
		[".*%.bash%.j2"] = "sh",
		[".*%.ya?ml%.j2"] = "yaml.ansible",
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
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		priority = 1000,
		config = function()
			require("github-theme").setup({
				options = {
					transparent = true,
					terminal_colors = true,
					dim_inactive = false,
				},
			})
			vim.cmd.colorscheme("github_dark_dimmed")
		end,
	},
	{ "nvim-tree/nvim-web-devicons" },
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		opts = {
			enable_git_status = false,
			sources = { "filesystem", "buffers" },
			filesystem = { filtered_items = { hide_gitignored = false } },
		},
	},
	-- Install Python and Ansible servers, then use Neovim's native LSP API.
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		config = function()
			local caps = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = caps })
			vim.lsp.config("basedpyright", {
				settings = { basedpyright = { analysis = { typeCheckingMode = "basic" } } },
			})
			require("mason-lspconfig").setup({
				ensure_installed = { "basedpyright", "ansiblels", "ruff", "lua_ls" },
				automatic_enable = { "basedpyright", "ansiblels", "ruff", "lua_ls" },
			})
			-- nixd is supplied by NixOS rather than Mason.
			vim.lsp.enable("nixd")
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = { "ansible-lint", "prettier", "stylua", "taplo", "tree-sitter-cli" },
		},
	},
	-- Autocomplete
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "none",
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-f>"] = { "accept", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
			},
			completion = {
				list = { selection = { preselect = true, auto_insert = false } },
				ghost_text = { enabled = true },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = function(bufnr)
				return {
					timeout_ms = vim.bo[bufnr].filetype == "yaml.ansible" and 5000 or 500,
					lsp_format = "fallback",
				}
			end,
			formatters_by_ft = {
				["yaml.ansible"] = { "ansible-lint" },
				json = { "prettier" },
				jsonc = { "prettier" },
				lua = { "stylua" },
				nix = { "nixfmt" },
				python = { "ruff_format" },
				toml = { "taplo" },
			},
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install({ "python", "yaml", "lua", "bash", "markdown", "nix" })
			end
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "yaml", "yaml.ansible", "lua", "sh", "bash", "markdown", "nix" },
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},
})

-- 4. KEYMAPS

-- Paste from the system clipboard without making visual replacements overwrite it
vim.keymap.set("x", "p", '"+p', { desc = "Paste from system clipboard" })

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
	end
end

vim.keymap.set("n", "<C-/>", "<cmd>lua toggle_terminal()<CR>", { desc = "Toggle Terminal" })
vim.keymap.set("t", "<C-/>", [[<C-\><C-n><cmd>lua toggle_terminal()<CR>]], { desc = "Toggle Terminal" })

-- Telescope Search Suite
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
vim.keymap.set("n", "<leader>sR", builtin.resume, { desc = "Search Resume" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "Search Buffer" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Terminal and Explorer
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")
-- LSP Attach Mappings
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local buf = event.buf
		vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = buf, desc = "References" })
		vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "Goto Definition" })
		vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = buf, desc = "Rename" })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Action" })
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
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })

vim.keymap.set("n", "<leader>ta", "<cmd>!uv run pytest<CR>", { desc = "Run All Tests (pytest)" })
