return {
  {
    "RRethy/base16-nvim",
    cond = vim.fn.has("linux") == 1,
    lazy = false,
    priority = 1000,
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "dark", transparent = true },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        if vim.fn.has("linux") == 1
          and vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/matugen.lua") == 1
        then
          require("matugen").setup()
        else
          vim.cmd.colorscheme("vscode")
        end
      end,
    },
  },
}
