local wezterm = require "wezterm"

local default_settings = {
  multiplexing = "None",
  assume_shell = 'Posix',
}

local function deep_setmetatable(user, default)
  user = user or {}
  for k, v in pairs(default) do
    if type(v) == "table" then
      user[k] = deep_setmetatable(user[k], v)
    else
      if user[k] == nil then
        user[k] = v
      end
    end
  end

  return user
end

local M = {}

M.formatter = function(icon, name, _)
  return wezterm.format({
    { Text = icon .. ' ' .. string.lower((name:sub(5))) }
  })
end

---@return _.wezterm.MuxDomain[]
local function get_ssh_domains()
  local domains = wezterm.mux.all_domains()
  local ssh_domains = {}
  for _, domain in ipairs(domains) do
    if domain:name():lower():find("^ssh") then
      table.insert(ssh_domains, domain)
    end
  end
  return ssh_domains
end

---@param mux_domains _.wezterm.MuxDomain[]
---@return table
local function get_choices(mux_domains)
  local choices = {}
  for _, domain in ipairs(mux_domains) do
    local name = domain:name()
    local label = domain:label()
    local icon = '󰢹'
    if name ~= "TermWizTerminalDomain" then
      table.insert(choices, {
        label = M.formatter(icon, name, label),
        id = name,
      })
    end
  end

  return choices
end

---@return _.wezterm.action_callback
function M.tab()
  return wezterm.action_callback(function(window, pane)
    local ssh_domains = get_ssh_domains()
    local choices = get_choices(ssh_domains)
    wezterm.emit('smart_ssh.fuzzy_selector.opened', window, pane)
    window:perform_action(
      wezterm.action.InputSelector({
        action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              wezterm.action.SpawnCommandInNewTab { domain = { DomainName = id } },
              inner_pane
            )
            wezterm.emit('smart_ssh.fuzzy_selector.selected', window, pane, id)
          else
            wezterm.emit('smart_ssh.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Host",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Host: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

---@return _.wezterm.action_callback
function M.vsplit()
  return wezterm.action_callback(function(window, pane)
    local ssh_domains = get_ssh_domains()
    local choices = get_choices(ssh_domains)
    wezterm.emit('smart_ssh.fuzzy_selector.opened', window, pane)
    window:perform_action(
      wezterm.action.InputSelector({
        action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              wezterm.action.SplitVertical { domain = { DomainName = id } },
              inner_pane
            )
            wezterm.emit('smart_ssh.fuzzy_selector.selected', window, pane, id)
          else
            wezterm.emit('smart_ssh.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Host",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Host: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

---@return _.wezterm.action_callback
function M.hsplit()
  return wezterm.action_callback(function(window, pane)
    local ssh_domains = get_ssh_domains()
    local choices = get_choices(ssh_domains)
    wezterm.emit('smart_ssh.fuzzy_selector.opened', window, pane)
    window:perform_action(
      wezterm.action.InputSelector({
        action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              wezterm.action.SplitHorizontal { domain = { DomainName = id } },
              inner_pane
            )
            wezterm.emit('smart_ssh.fuzzy_selector.selected', window, pane, id)
          else
            wezterm.emit('smart_ssh.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Host",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Host: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

function M.apply_to_config(config, user_settings)
  local opts = deep_setmetatable(user_settings or {}, default_settings)
  local ssh_domains = {}
  for host, _ in pairs(wezterm.enumerate_ssh_hosts()) do
    table.insert(ssh_domains, {
      name = "ssh:" .. host,
      remote_address = host,
      multiplexing = opts.multiplexing,
      assume_shell = opts.assume_shell,
    })
  end
  config.ssh_domains = ssh_domains
end

return M
