return {
  { import = "lazyvim.plugins.extras.lang.yaml" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "jsonnet" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      require("work.gap_application").setup()
      require("work.kubernetes").setup()
    end,
    opts = function(_, opts)
      opts.servers.jsonnet_ls = vim.tbl_deep_extend("force", opts.servers.jsonnet_ls or {}, {
        cmd = { "jsonnet-language-server", "--eval-diags", "--lint" },
        keys = {
          { "K", function() require("work.gap_application").hover() end, desc = "Show Application CRD or Jsonnet help" },
        },
      })
      local yaml = opts.servers.yamlls.settings.yaml
      yaml.schemas = vim.tbl_extend("force", yaml.schemas or {}, require("work.kubernetes").schemas())
    end,
  },
}
