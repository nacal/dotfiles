local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------------------------------------------
-- Pokemon Background
----------------------------------------------------
local POKEMON_CACHE_DIR = wezterm.home_dir .. "/.cache/wezterm/pokemon"
local POKEMON_TOTAL = 1025

wezterm.run_child_process({ "mkdir", "-p", POKEMON_CACHE_DIR })

local function download_pokemon(id)
  local filename = string.format("%04d.png", id)
  local path = POKEMON_CACHE_DIR .. "/" .. filename
  local f = io.open(path, "r")
  if f then
    local size = f:seek("end")
    f:close()
    if size and size > 0 then
      return path
    end
  end
  local success, _, stderr = wezterm.run_child_process({
    "curl", "-sfL", "-o", path, "--max-time", "5",
    "https://www.pokemon.co.jp/ex/30th_logo/assets/img/download/" .. filename,
  })
  if success then
    return path
  end
  wezterm.log_warn("Failed to download Pokemon " .. filename .. ": " .. (stderr or ""))
  return nil
end

local function pokemon_background(image_path)
  if not image_path then
    return {
      { source = { Color = "#193549" }, width = "100%", height = "100%", opacity = 1.0 },
    }
  end
  return {
    {
      source = { File = image_path },
      repeat_x = "NoRepeat",
      repeat_y = "NoRepeat",
      horizontal_align = "Center",
      vertical_align = "Middle",
      width = "Contain",
      height = "Contain",
      hsb = { brightness = 0.1 },
      opacity = 0.85,
    },
    {
      source = { Color = "#193549" },
      width = "100%",
      height = "100%",
      opacity = 0.78,
    },
  }
end

-- ポケモン背景のオンオフ切り替え (LEADER + p)
wezterm.on("toggle-pokemon-bg", function(window, _pane)
  if wezterm.GLOBAL.pokemon_enabled == nil then
    wezterm.GLOBAL.pokemon_enabled = true
  end
  wezterm.GLOBAL.pokemon_enabled = not wezterm.GLOBAL.pokemon_enabled
  wezterm.GLOBAL.current_pokemon_pane = "" -- 再描画を強制

  local overrides = window:get_config_overrides() or {}
  if not wezterm.GLOBAL.pokemon_enabled then
    overrides.background = nil
    overrides.window_background_opacity = 0.6
    overrides.macos_window_background_blur = 5
  else
    overrides.window_background_opacity = nil
    overrides.macos_window_background_blur = nil
  end
  window:set_config_overrides(overrides)
end)

-- ペイン破棄時にpokemon_mapエントリとIDファイルをクリーンアップ
wezterm.on("pane-destroyed", function(pane)
  local pane_id = tostring(pane:pane_id())
  if wezterm.GLOBAL.pokemon_map then
    wezterm.GLOBAL.pokemon_map[pane_id] = nil
  end
  if wezterm.GLOBAL.pokemon_retry then
    wezterm.GLOBAL.pokemon_retry[pane_id] = nil
  end
  os.remove(POKEMON_CACHE_DIR .. "/pane_" .. pane_id .. ".id")
end)

wezterm.on("update-status", function(window, pane)
  local pane_id = tostring(pane:pane_id())

  if not wezterm.GLOBAL.pokemon_map then
    wezterm.GLOBAL.pokemon_map = {}
  end
  if not wezterm.GLOBAL.pokemon_retry then
    wezterm.GLOBAL.pokemon_retry = {}
  end
  if not wezterm.GLOBAL.current_pokemon_pane then
    wezterm.GLOBAL.current_pokemon_pane = ""
  end
  if wezterm.GLOBAL.pokemon_enabled == nil then
    wezterm.GLOBAL.pokemon_enabled = true
  end

  -- ポケモン背景が無効の場合はスキップ
  if not wezterm.GLOBAL.pokemon_enabled then
    return
  end

  -- zshrc が書き出したポケモンIDファイルを読む（リトライ上限10回）
  if not wezterm.GLOBAL.pokemon_map[pane_id] then
    local retries = wezterm.GLOBAL.pokemon_retry[pane_id] or 0
    if retries < 10 then
      local id_file = POKEMON_CACHE_DIR .. "/pane_" .. pane_id .. ".id"
      local f = io.open(id_file, "r")
      if f then
        local pokemon_num = f:read("*l")
        f:close()
        if pokemon_num and #pokemon_num > 0 then
          local path = download_pokemon(tonumber(pokemon_num))
          wezterm.GLOBAL.pokemon_map[pane_id] = path or ""
        end
        wezterm.GLOBAL.pokemon_retry[pane_id] = nil
      else
        wezterm.GLOBAL.pokemon_retry[pane_id] = retries + 1
      end
    end
  end

  -- ペインが切り替わった時だけ背景を更新（無限ループ防止）
  if wezterm.GLOBAL.pokemon_map[pane_id] and wezterm.GLOBAL.current_pokemon_pane ~= pane_id then
    wezterm.GLOBAL.current_pokemon_pane = pane_id
    local pokemon_path = wezterm.GLOBAL.pokemon_map[pane_id]
    if pokemon_path == "" then pokemon_path = nil end

    -- 背景テーブルをキャッシュして再利用
    if not wezterm.GLOBAL.bg_cache then
      wezterm.GLOBAL.bg_cache = {}
    end
    local cache_key = pokemon_path or "__none__"
    if not wezterm.GLOBAL.bg_cache[cache_key] then
      wezterm.GLOBAL.bg_cache[cache_key] = pokemon_background(pokemon_path)
    end

    local overrides = window:get_config_overrides() or {}
    overrides.background = wezterm.GLOBAL.bg_cache[cache_key]
    window:set_config_overrides(overrides)
  end
end)

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

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーの背景色は update-status の pokemon_background で管理

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
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
