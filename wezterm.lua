local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Из-за возможных проблем WezTerm с Wayland
config.enable_wayland = false

-- Цветовая схема
config.color_scheme = "Catppuccin Mocha"

-- Шрифт
config.font = wezterm.font_with_fallback({
    {
        family = "JetBrains Mono",
        weight = "Medium",
    },
    "Noto Color Emoji",
})

config.font_size = 12.0

-- Высота строк
config.line_height = 1.05

-- Полупрозрачный фон
config.window_background_opacity = 0.94

-- Отступы текста от границ окна
config.window_padding = {
    left = 12,
    right = 12,
    top = 10,
    bottom = 10,
}

-- Размер окна при запуске
config.initial_cols = 120
config.initial_rows = 32

-- Вкладки
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- Убираем лишние элементы заголовка, оставляем изменение размера
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Курсор
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- Полоса прокрутки
config.enable_scroll_bar = false

-- История терминала
config.scrollback_lines = 10000

-- Не спрашивать подтверждение при закрытии
config.window_close_confirmation = "NeverPrompt"

-- Небольшое затемнение неактивных панелей
config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
}

local act = wezterm.action

-- Leader: Ctrl+A, затем следующая клавиша
config.leader = {
    key = "a",
    mods = "CTRL",
    timeout_milliseconds = 1500,
}

config.keys = {
    -- Разделить слева/справа
    {
        key = "|",
        mods = "LEADER|SHIFT",
        action = act.SplitHorizontal {
            domain = "CurrentPaneDomain",
        },
    },

    -- Разделить сверху/снизу
    {
        key = "-",
        mods = "LEADER",
        action = act.SplitVertical {
            domain = "CurrentPaneDomain",
        },
    },

    -- Переключение между панелями
    {
        key = "h",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Left"),
    },
    {
        key = "j",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Down"),
    },
    {
        key = "k",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Up"),
    },
    {
        key = "l",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Right"),
    },

    -- Изменение размера панели
    {
        key = "H",
        mods = "LEADER|SHIFT",
        action = act.AdjustPaneSize { "Left", 5 },
    },
    {
        key = "J",
        mods = "LEADER|SHIFT",
        action = act.AdjustPaneSize { "Down", 5 },
    },
    {
        key = "K",
        mods = "LEADER|SHIFT",
        action = act.AdjustPaneSize { "Up", 5 },
    },
    {
        key = "L",
        mods = "LEADER|SHIFT",
        action = act.AdjustPaneSize { "Right", 5 },
    },

    -- Развернуть активную панель
    {
        key = "z",
        mods = "LEADER",
        action = act.TogglePaneZoomState,
    },

    -- Закрыть активную панель с подтверждением
    {
        key = "x",
        mods = "LEADER",
        action = act.CloseCurrentPane {
            confirm = true,
        },
    },
}

return config
