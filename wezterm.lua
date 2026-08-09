local wezterm = require("wezterm")

local config = wezterm.config_builder()

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local act = wezterm.action

local smart_ssh = wezterm.plugin.require(
    "https://github.com/DavidRR-F/smart_ssh.wezterm"
)

-- Получаем SSH-хосты штатным механизмом WezTerm
local default_ssh_domains = wezterm.default_ssh_domains()

-- Оставляем только обычные SSH domains.
-- SSHMUX требует WezTerm на удалённой машине.
config.ssh_domains = {}

for _, domain in ipairs(default_ssh_domains) do
    if domain.name:match("^SSH:") then
        domain.multiplexing = "None"
        domain.assume_shell = "Posix"

        table.insert(config.ssh_domains, domain)
    end
end


-- Из-за возможных проблем WezTerm с Wayland
config.enable_wayland = false

-- Цветовая схема
config.color_scheme = "Catppuccin Mocha"

-- Шрифт
config.font = wezterm.font_with_fallback({{
    family = "JetBrains Mono",
    weight = "Medium"
}, "Noto Color Emoji"})

config.font_size = 12.0

-- Высота строк
config.line_height = 1.05

-- Полупрозрачный фон
config.window_background_opacity = 1

-- Отступы текста от границ окна
config.window_padding = {
    left = 12,
    right = 16,
    top = 10,
    bottom = 10
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
config.window_decorations = "TITLE|RESIZE"

-- Курсор
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 50

-- Полоса прокрутки
config.enable_scroll_bar = true

-- История терминала
config.scrollback_lines = 10000

-- Не спрашивать подтверждение при закрытии
config.window_close_confirmation = "NeverPrompt"

-- Небольшое затемнение неактивных панелей
config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7
}


-- Leader: Ctrl+A, затем следующая клавиша
config.leader = {
    key = "a",
    mods = "CTRL",
    timeout_milliseconds = 1500
}

config.keys = { -- Разделить слева/справа
{
    key = "|",
    mods = "LEADER|SHIFT",
    action = act.SplitHorizontal {
        domain = "CurrentPaneDomain"
    }
}, -- Разделить сверху/снизу
{
    key = "-",
    mods = "LEADER",
    action = act.SplitVertical {
        domain = "CurrentPaneDomain"
    }
}, -- Переключение между панелями
{
    key = "h",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Left")
}, {
    key = "j",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Down")
}, {
    key = "k",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Up")
}, {
    key = "l",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Right")
}, -- Изменение размера панели
{
    key = "H",
    mods = "LEADER|SHIFT",
    action = act.AdjustPaneSize {"Left", 5}
}, {
    key = "J",
    mods = "LEADER|SHIFT",
    action = act.AdjustPaneSize {"Down", 5}
}, {
    key = "K",
    mods = "LEADER|SHIFT",
    action = act.AdjustPaneSize {"Up", 5}
}, {
    key = "L",
    mods = "LEADER|SHIFT",
    action = act.AdjustPaneSize {"Right", 5}
}, -- Развернуть активную панель
{
    key = "z",
    mods = "LEADER",
    action = act.TogglePaneZoomState
}, -- Закрыть активную панель с подтверждением
{
    key = "s",
    mods = "LEADER",
    action = smart_ssh.tab(),
},
{
    key = "a",
    mods = "LEADER",
    action = smart_ssh.vsplit(),
},
{
    key = "d",
    mods = "LEADER",
    action = smart_ssh.hsplit(),
},
{
    key = "w",
    mods = "LEADER",
    action = act.CloseCurrentTab 
    {
        confirm = true
    }
},
{
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane {
        confirm = true
    }
}}


tabline.setup({
    options = {
        icons_enabled = true,
        theme = 'Catppuccin Mocha',
        tabs_enabled = true,
        theme_overrides = {},
        section_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider
        },
        component_separators = {
            left = wezterm.nerdfonts.pl_left_soft_divider,
            right = wezterm.nerdfonts.pl_right_soft_divider
        },
        tab_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider
        }
    },
    sections = {
        tabline_a = {
            'domain',
            domain_to_icon = {
                default = wezterm.nerdfonts.md_monitor,
                ssh = wezterm.nerdfonts.md_ssh,
                wsl = wezterm.nerdfonts.md_microsoft_windows,
                docker = wezterm.nerdfonts.md_docker,
                unix = wezterm.nerdfonts.cod_terminal_linux
            }
        },
        tabline_b = {},
        tabline_c = {' '},
        tab_active = {'index', {
            'process',
            padding = {
                left = 0,
                right = 1
            }
        }},
        tab_inactive = {'index', {
            'process',
            padding = {
                left = 0,
                right = 1
            }
        }},
        tabline_x = {},
        tabline_y = {},
        tabline_z = {}

    },
    extensions = {}
})

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 48


local context_menu = act.InputSelector {
    title = "Terminal Menu",

    description = "Выберите действие",

    alphabet = "123456",

    choices = {{
        id = "copy",
        label = "1  Copy"
    }, {
        id = "paste",
        label = "2  Paste"
    }, {
        id = "new_tab",
        label = "3  New Tab"
    }, {
        id = "split_horizontal",
        label = "4  Split Horizontal"
    }, {
        id = "split_vertical",
        label = "5  Split Vertical"
    }, {
        id = "close_pane",
        label = "6  Close Pane"
    }},

    action = wezterm.action_callback(function(window, pane, id, label)
        if id == nil then
            return
        end

        if id == "copy" then
            window:perform_action(act.CopyTo("Clipboard"), pane)

        elseif id == "paste" then
            window:perform_action(act.PasteFrom("Clipboard"), pane)

        elseif id == "new_tab" then
            window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)

        elseif id == "split_horizontal" then
            window:perform_action(act.SplitHorizontal {
                domain = "CurrentPaneDomain"
            }, pane)

        elseif id == "split_vertical" then
            window:perform_action(act.SplitVertical {
                domain = "CurrentPaneDomain"
            }, pane)

        elseif id == "close_pane" then
            window:perform_action(act.CloseCurrentPane {
                confirm = true
            }, pane)
        end
    end)
}

local context_menu = act.InputSelector {
    title = "Terminal Menu",

    description = "Выберите действие",

    alphabet = "123456",

    choices = {{
        id = "copy",
        label = "1  Copy"
    }, {
        id = "paste",
        label = "2  Paste"
    }, {
        id = "new_tab",
        label = "3  New Tab"
    }, {
        id = "split_horizontal",
        label = "4  Split Horizontal"
    }, {
        id = "split_vertical",
        label = "5  Split Vertical"
    }, {
        id = "close_pane",
        label = "6  Close Pane"
    }},

    action = wezterm.action_callback(function(window, pane, id, label)
        if id == nil then
            return
        end

        if id == "copy" then
            window:perform_action(act.CopyTo("Clipboard"), pane)

        elseif id == "paste" then
            window:perform_action(act.PasteFrom("Clipboard"), pane)

        elseif id == "new_tab" then
            window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)

        elseif id == "split_horizontal" then
            window:perform_action(act.SplitHorizontal {
                domain = "CurrentPaneDomain"
            }, pane)

        elseif id == "split_vertical" then
            window:perform_action(act.SplitVertical {
                domain = "CurrentPaneDomain"
            }, pane)

        elseif id == "close_pane" then
            window:perform_action(act.CloseCurrentPane {
                confirm = true
            }, pane)
        end
    end)
}

-- ПКМ открывает меню
config.mouse_bindings = {{
    event = {
        Up = {
            streak = 1,
            button = "Right"
        }
    },

    mods = "NONE",

    action = context_menu
}}

config.status_update_interval = 1000

return config