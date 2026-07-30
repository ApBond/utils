#!/bin/bash

add-apt-repository universe
apt-get update
#install packet
apt-get install -y git build-essential cmake curl gnupg zsh
#install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#install wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key |
    gpg --yes --dearmor \
        -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    tee /etc/apt/sources.list.d/wezterm.list

chmod 644 /usr/share/keyrings/wezterm-fury.gpg
apt-get update -y
apt-get install -y wezterm
#configure wezterm
mkdir -p ~/.config/wezterm
cp -f wezterm.lua ~/.config/wezterm/wezterm.lua
#wezterm default terminal
printf '%s\n' \
  'org.wezfurlong.wezterm.desktop' \
  > ~/.config/ubuntu-xdg-terminals.list


apt-get install -y eza zsh-autosuggestions zsh-syntax-highlighting fzf btop jq tree ncdu git-delta

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
curl -sS https://starship.rs/install.sh | sh

cp -f starship.toml ~/.config/starship.toml
cp -f zshrc ~/.zshrc

git config --global core.pager delta && \
git config --global interactive.diffFilter 'delta --color-only' && \
git config --global delta.navigate true && \
git config --global delta.line-numbers true && \
git config --global delta.side-by-side false && \
git config --global merge.conflictStyle zdiff3


