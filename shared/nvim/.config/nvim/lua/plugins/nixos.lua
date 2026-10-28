-- Mason's generic Linux binaries do not run on NixOS. Install these tools
-- through Nix instead, and let language servers resolve from the normal PATH.
if not vim.uv.fs_stat("/etc/NIXOS") then
  return {}
end

return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      for _, server in pairs(opts.servers) do
        if type(server) == "table" then
          server.mason = false
        end
      end
    end,
  },
}
