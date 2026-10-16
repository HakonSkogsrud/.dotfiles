
local function jinja_filetype(path)
  local normalized_path = path:lower()
  if normalized_path:match("%.sh%.j2$") or normalized_path:match("%.bash%.j2$") then
    return "sh"
  end
  if normalized_path:match("%.ya?ml%.j2$") then
    return "yaml.ansible"
  end
  return "jinja"
end

vim.filetype.add({
  extension = {
    j2 = jinja_filetype,
  },
})

vim.api.nvim_create_user_command("GapApplicationValidate", function()
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= "jsonnet" or not file:match("%.jsonnet$") then
    vim.notify("GapApplicationValidate requires a rendered Application .jsonnet buffer", vim.log.levels.ERROR)
    return
  end

  local rendered = vim.system({ "jsonnet", file }, { text = true }):wait()
  if rendered.code ~= 0 then
    vim.fn.setqflist({}, " ", {
      title = "Jsonnet rendering",
      lines = vim.split(rendered.stderr, "\n", { trimempty = true }),
    })
    vim.cmd("copen")
    return
  end

  local manifest = vim.json.decode(rendered.stdout)
  local applications = {}
  for _, item in ipairs(manifest.kind == "List" and manifest.items or { manifest }) do
    if item.apiVersion == "gap.io/v1" and item.kind == "Application" then
      applications[#applications + 1] = item
    end
  end
  if #applications == 0 then
    vim.notify("No gap.io/v1 Application resources were rendered", vim.log.levels.ERROR)
    return
  end

  local validation = vim.system(
    { "kubectl", "create", "--dry-run=client", "--validate=strict", "-f", "-" },
    {
      text = true,
      stdin = vim.json.encode({
        apiVersion = "v1",
        kind = "List",
        items = applications,
      }),
    }
  ):wait()
  local output = validation.code == 0 and validation.stdout or validation.stderr

  vim.fn.setqflist({}, " ", {
    title = "gap.io/v1 Application validation",
    lines = vim.split(output, "\n", { trimempty = true }),
  })
  vim.cmd("copen")
end, {
  desc = "Render the current Jsonnet file and validate Applications against the cluster CRD",
})

require("config.gap_application").setup()

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
