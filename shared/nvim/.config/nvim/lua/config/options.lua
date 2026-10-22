
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

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
