local M = {}

local schema_path = vim.fn.stdpath("data") .. "/schemas/gap-application-v1.json"
local schema

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function load_schema()
  if schema then
    return schema
  end
  if vim.fn.filereadable(schema_path) == 0 then
    notify("Run :GapApplicationSchemaUpdate to enable gap.io Application help", vim.log.levels.WARN)
    return
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(schema_path), "\n"))
  if not ok then
    notify("Could not read " .. schema_path .. ": " .. decoded, vim.log.levels.ERROR)
    return
  end
  schema = decoded
  return schema
end

local function find_property(node, name, path)
  if not node or type(node) ~= "table" then
    return
  end
  for key, property in pairs(node.properties or {}) do
    local property_path = path .. "." .. key
    if key == name then
      return property, property_path
    end
    local nested, nested_path = find_property(property, name, property_path)
    if nested then
      return nested, nested_path
    end
  end
  return find_property(node.items, name, path .. "[]")
end

local function show_help(lines, title)
  vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    focusable = true,
    title = title,
    title_pos = "center",
  })
end

local function describe_property(name, direct_spec_field)
  local document = load_schema()
  if not document then
    return
  end

  local property, property_path
  if direct_spec_field then
    local spec = document.properties and document.properties.spec
    property = spec and spec.properties and spec.properties[name]
    property_path = property and "Application.spec." .. name
  else
    property, property_path = find_property(document, name, "Application")
  end
  if not property then
    return
  end

  local lines = {
    "# `" .. property_path .. "`",
    "",
    property.description or "No description is provided by the CRD.",
  }
  if property.type then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "**Type:** `" .. property.type .. "`"
  end
  if property.default ~= nil then
    lines[#lines + 1] = "**Default:** `" .. vim.inspect(property.default) .. "`"
  end
  if property.enum then
    lines[#lines + 1] = "**Allowed values:** `" .. table.concat(property.enum, "`, `") .. "`"
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "_Source: `applications.gap.io`, `gap.io/v1` CRD_"

  show_help(lines, " Application CRD ")
  return true
end

local function describe_variable(name)
  show_help({
    "# `$." .. name .. "`",
    "",
    "`$." .. name .. "` reads the `" .. name .. "` field from the current Jsonnet object.",
    "",
    "This value is supplied by an object that extends or invokes this library. Use `gd` to navigate to its definition or search for `" .. name .. "::` in the calling `app.jsonnet`.",
  }, " Jsonnet variable ")
end

function M.update_schema()
  local result = vim.system({ "kubectl", "get", "crd", "applications.gap.io", "-o", "json" }, { text = true }):wait()
  if result.code ~= 0 then
    notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  local crd = vim.json.decode(result.stdout)
  local version
  for _, candidate in ipairs(crd.spec.versions or {}) do
    if candidate.name == "v1" then
      version = candidate
      break
    end
  end
  if not version or not version.schema or not version.schema.openAPIV3Schema then
    notify("The applications.gap.io CRD does not contain a v1 OpenAPI schema", vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(schema_path, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(version.schema.openAPIV3Schema) }, schema_path)
  schema = version.schema.openAPIV3Schema
  notify("Updated gap.io/v1 Application schema: " .. schema_path)
end

function M.hover()
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local word = vim.fn.expand("<cword>")
  local before_cursor = line:sub(1, column)
  local is_object_field = before_cursor:match("%$%.[%w_]+$") ~= nil
    or line:match("%$%." .. vim.pesc(word) .. "%f[^%w_]") ~= nil

  if is_object_field then
    if describe_property(word, true) then
      return
    end
    describe_variable(word)
    return
  end
  if describe_property(word) then
    return
  end
  vim.lsp.buf.hover()
end

local function set_hover_keymap(buffer)
  vim.keymap.set("n", "K", M.hover, {
    buffer = buffer,
    desc = "Show Application CRD or Jsonnet help",
  })
end

function M.setup()
  vim.api.nvim_create_user_command("GapApplicationSchemaUpdate", M.update_schema, {
    desc = "Update the cached gap.io/v1 Application CRD schema",
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("gap_application_help", { clear = true }),
    pattern = "jsonnet",
    callback = function(event)
      set_hover_keymap(event.buf)
    end,
  })

end

return M
