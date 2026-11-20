-- Rex config — managed by ~/dotfiles.
-- `rex config check` validates this file, `rex config reload` applies it,
-- `rex keymap` lists the current bindings.

-- Mac-style text navigation. Sends the same key codes as config/ghostty/config;
-- fish and nvim turn them into movement and shift-selection.
--   option+←/→  word        cmd+←/→  line start/end       (+shift = select)
--   option+⌫    delete word cmd+⌫    delete to line start
local keys = {
  ["alt+left"] = "alt+b",
  ["alt+right"] = "alt+f",
  ["cmd+left"] = "home",
  ["cmd+right"] = "end",
  ["alt+shift+left"] = "alt+shift+left",
  ["alt+shift+right"] = "alt+shift+right",
  ["cmd+shift+left"] = "shift+home",
  ["cmd+shift+right"] = "shift+end",
  ["alt+backspace"] = "alt+backspace",
  ["cmd+backspace"] = "ctrl+u",
}
for from, to in pairs(keys) do
  rex.bind(from, "pane.send_key", { key = to })
end
