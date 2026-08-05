#!/usr/bin/env bash

set -Eeuo pipefail

trap 'printf "Ошибка: команда завершилась неудачно (строка %s).\n" "$LINENO" >&2' ERR

if [[ $EUID -eq 0 ]]; then
    printf 'Запустите скрипт от обычного пользователя, без sudo:\n  ./install.sh\n' >&2
    exit 1
fi

for command in sudo apt-get; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Не найдена необходимая команда: %s\n' "$command" >&2
        exit 1
    fi
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
TARGET_USER="$(id -un)"

for config_file in wezterm.lua starship.toml .zshrc; do
    if [[ ! -r "$SCRIPT_DIR/$config_file" ]]; then
        printf 'Не найден файл конфигурации: %s\n' "$SCRIPT_DIR/$config_file" >&2
        exit 1
    fi
done

# Запрашиваем права администратора заранее, чтобы не прерывать установку позже.
sudo -v

# Базовые пакеты и подключение репозитория universe.
sudo apt-get update
sudo apt-get install -y software-properties-common curl gnupg
sudo add-apt-repository -y universe

# eza нет в штатных репозиториях Ubuntu 22.04, поэтому подключаем
# APT-репозиторий, рекомендованный проектом eza.
sudo install -d -m 755 /etc/apt/keyrings
curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc |
    sudo gpg --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
printf '%s\n' \
    'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' |
    sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

sudo apt-get update
sudo apt-get install -y \
    git build-essential cmake curl gnupg zsh \
    eza zsh-autosuggestions zsh-syntax-highlighting \
    fzf btop jq tree ncdu bat zoxide

# Oh My Zsh: без смены shell и запуска интерактивного zsh во время установки.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Устанавливаем Zsh как shell по умолчанию для текущего пользователя.
ZSH_BIN="$(command -v zsh)"
if [[ ${SHELL:-} != "$ZSH_BIN" ]]; then
    sudo chsh -s "$ZSH_BIN" "$TARGET_USER"
fi

# Репозиторий и пакет WezTerm.
curl -fsSL https://apt.fury.io/wez/gpg.key |
    sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg

printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null

sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt-get update
sudo apt-get install -y wezterm

# Пользовательские конфиги.
mkdir -p "$CONFIG_DIR/wezterm" "$LOCAL_BIN"
install -m 644 "$SCRIPT_DIR/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"
printf '%s\n' 'org.wezfurlong.wezterm.desktop' \
    >"$CONFIG_DIR/ubuntu-xdg-terminals.list"

# Starship устанавливается в пользовательский каталог.
# Zoxide берётся из universe вместе с остальными пакетами.
curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN"

install -m 644 "$SCRIPT_DIR/starship.toml" "$CONFIG_DIR/starship.toml"
install -m 644 "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# git config --global автоматически создаст ~/.gitconfig, если файла ещё нет.
# git-delta нет в штатных репозиториях Ubuntu 22.04. Если он уже
# установлен другим способом, включаем его настройки.
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side false
fi

# Git 2.34 из Ubuntu 22.04 ещё не поддерживает zdiff3.
git config --global merge.conflictStyle diff3

printf '\nУстановка завершена успешно.\n'
printf 'Перезапустите терминал или выполните: exec zsh\n'
