# ⚡ Smart SSH

A faster way to search and attach to ssh sessions in wezterm. Inspired by [smart_workpace_switcher.wezterm](https://github.com/MLFlexer/smart_workspace_switcher.wezterm)

## Quick Look

#### Dependencies

There are no package dependencies, but you need to configured your
`.ssh/config` [Here](https://wezfurlong.org/wezterm/config/lua/wezterm/enumerate_ssh_hosts.html) to select ssh domains using auto-configuration with this plugin.

### 🚀 Install

This is a wezterm plugin. It can be installed by importing the repo and calling the `apply_to_config` function. It is important that the `apply_to_config` function is called after keys and key_tables have been set.
```lua 
local smart_ssh = wezterm.plugin.require("https://github.com/DavidRR-F/smart_ssh.wezterm")
domains.apply_to_config(config)
```

### 🎨 Configuration

The `apply_to_config` function takes a second parameter opts. To override any options simply pass a table of the desired changes.

```lua
domains.apply_to_config(
  config,
  {
    multiplexing = "None"
    assume_shell = "Posix"
  }
)
```

You can set keys to spawn new windows/tabs with the selected ssh session

```lua
config.keys = {
  -- Spawn ssh session in new tab
  { key = "s",     mods = "LEADER|SHIFT", action = smart_ssh.tab() },
  -- Spawn ssh session in horizontal window
  { key = "5",     mods = "LEADER",       action = smart_ssh.hsplit() },
  -- Spawn ssh session in vertical window
  { key = "'",     mods = "LEADER",       action = smart_ssh.vsplit() },
}
```

You can set a custom [wezterm format](https://wezfurlong.org/wezterm/config/lua/wezterm/format.html) for the domain fuzzy selector items 

```lua 
smart_ssh.formatter = function(icon, name, label)
  return wezterm.format({
    { Attribute = { Italic = true } },
    { Foreground = { AnsiColor = 'Fuchsia' } },
    { Background = { Color = 'blue' } },
    { Text = icon .. ' ' .. name .. ': ' .. label },
  })
end
```

### 🛠️ Defaults

These are the current default setting the can be overridden on your `apply_to_config` function

```lua 
{
  multiplexing = 'None',
  assume_shell = 'Posix',
}
```

This is the current default formatter function that can be overridden 

```lua 
domains.formatter = function(icon, name, _)
    return wezterm.format({ 
        { Text = icon .. ' ' .. string.lower(name) } 
    })
end
```

### 🔔 Events

`smart_ssh.fuzzy_selector.opened`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |

`smart_ssh.fuzzy_selector.selected`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |
| id        | Domain ID |

`smart_ssh.fuzzy_selector.canceled`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |

### Tabline.wez integration

```lua
local tabline = wez.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  ...
  extensions = {
    {
      'smart_ssh',
      events = {
        show = 'smart_ssh.fuzzy_selector.opened',
        hide = {
          'smart_ssh.fuzzy_selector.canceled',
          'smart_ssh.fuzzy_selector.selected',
        },
      },
      ...
    },
    ...
  },
})
```

> See [tabline.wez](https://github.com/michaelbrusegard/tabline.wez) for more info
