#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
pushd nerd-fonts
git sparse-checkout add patched-fonts/FiraCode && ./install.sh FiraCode
popd
rm -rf nerd-fonts

if [[ "$OSTYPE" == "darwin"* ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  /opt/homebrew/in/brew install \
    neovim \
    tmux \
    starship \
    lua \
    luarocks \
    miniforge \
    ripgrep \
    fzf \
    stow \
    bash \
    karabiner-elements \
    hammerspoon \
    wezterm \
    coreutils

  defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

  if [[ $(command -v gcert) ]]; then
    sudo mule install roadwarrior
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # TODO

  if [[ $(command -v gcert) ]]; then
    sudo glinux-add-repo bugged

    sudo apt update

    sudo apt install -y \
      gnubby-wrappers \
      glinux-vim \
      cidermux \
      clsearch \
      bugged
  fi
fi

stow -d "$DIR"/.. -t "$HOME" --stow . -R

git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source-file $HOME/.config/tmux/tmux.conf
