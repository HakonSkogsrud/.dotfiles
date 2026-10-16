return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "jsonnet" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonnet_ls = {
          cmd = { "jsonnet-language-server", "--eval-diags", "--lint" },
          keys = {
            { "K", function() require("config.gap_application").hover() end, desc = "Show Application CRD or Jsonnet help" },
          },
        },
      },
    },
  },
}
