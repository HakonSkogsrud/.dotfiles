local M = {}
local directory = vim.fn.stdpath("data") .. "/schemas/work-kubernetes"
local groups = { ["agentgateway.dev"] = true, ["gateway.networking.k8s.io"] = true }

function M.schemas()
  local schemas = {}
  for _, file in ipairs(vim.fn.glob(directory .. "/*.json", false, true)) do
    local kind = vim.fn.fnamemodify(file, ":t:r")
    local patterns = {}
    local names = { kind }
    if kind == "agentgatewayparameters" then
      names[#names + 1] = "gatewayparameters"
    end
    for _, name in ipairs(names) do
      for _, extension in ipairs({ "yaml", "yml" }) do
        patterns[#patterns + 1] = "**/apps/agentgateway/**/config/**/" .. name .. "." .. extension
        patterns[#patterns + 1] = "**/apps/agentgateway/**/config/**/" .. name .. "-*." .. extension
      end
    end
    schemas[vim.uri_from_fname(file)] = patterns
  end
  return schemas
end

function M.update()
  local result = vim.system({ "kubectl", "get", "crd", "-o", "json", "--request-timeout=20s" }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end
  local documents = {}
  for _, crd in ipairs(vim.json.decode(result.stdout).items or {}) do
    if groups[crd.spec.group] then
      local versions = {}
      for _, version in ipairs(crd.spec.versions) do
        if version.served and version.schema and version.schema.openAPIV3Schema then
          local schema = vim.deepcopy(version.schema.openAPIV3Schema)
          schema.properties.apiVersion = { type = "string", enum = { crd.spec.group .. "/" .. version.name } }
          schema.properties.kind = { type = "string", enum = { crd.spec.names.kind } }
          versions[#versions + 1] = schema
        end
      end
      if #versions > 0 then
        documents[crd.spec.names.kind:lower()] = { oneOf = versions }
      end
    end
  end
  if vim.tbl_isempty(documents) then
    vim.notify("No served Agentgateway or Gateway API CRD schemas found in the current cluster", vim.log.levels.ERROR)
    return
  end
  vim.fn.mkdir(directory, "p")
  for kind, document in pairs(documents) do
    vim.fn.writefile({ vim.json.encode(document) }, directory .. "/" .. kind .. ".json")
  end
  vim.notify("Updated work Kubernetes schemas from the current cluster. Run :LspRestart yamlls to reload.")
end

function M.setup()
  vim.api.nvim_create_user_command("WorkKubernetesSchemaUpdate", M.update, {
    desc = "Cache Agentgateway and Gateway API schemas from the current kubectl context",
  })
end

return M
