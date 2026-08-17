local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------------------------------------------
-- Pane Focus
----------------------------------------------------
-- 非アクティブペインを暗くしてフォーカス中のペインを分かりやすくする
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.3,
}

config.scrollback_lines = 3500
config.automatically_reload_config = true
config.font = wezterm.font("HackGen Console NF", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.tab_max_width = 50

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバー自体は透過させ、下の config.background レイヤーを見せる
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- ウィンドウ全体（タブバー領域含む）を一枚のレイヤーで塗る。
-- window_frame や format-tab-title 側の色指定ではタブバーとペインの透過率が揃わないため。
config.background = {
  { source = { Color = "#193549" }, width = "100%", height = "100%", opacity = 0.85 },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- 背景色 / タブ同士の境界線を非表示
config.colors = {
  background = "#193549",
  tab_bar = {
    inactive_tab_edge = "none",
  },
  split = "#ffc600",
}

-- タブの形をカスタマイズ（四角 + 透過の隙間）
local function tab_title(tab)
  local title = tab.active_pane.title or ""
  local index = tab.tab_index + 1
  if title ~= "" then
    return index .. " │ " .. title
  end
  return tostring(index)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local title = "   " .. wezterm.truncate_right(tab_title(tab), max_width - 6) .. "   "
  return {
    { Background = { Color = "none" } },
    { Text = " " },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = "none" } },
    { Text = " " },
  }
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = ";", mods = "SUPER", timeout_milliseconds = 2000 }

----------------------------------------------------
-- resurrect.wezterm (セッション保存・復元)
----------------------------------------------------
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- 5分おきにワークスペース/ウィンドウ状態を自動保存
resurrect.state_manager.periodic_save({
  interval_seconds = 300,
  save_workspaces = true,
  save_windows = true,
})

-- 起動時に前回状態を復元
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

return config
