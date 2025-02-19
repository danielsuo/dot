#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
pushd nerd-fonts
git sparse-checkout add patched-fonts/FiraCode && ./install.sh FiraCode
popd
rm -rf nerd-fonts

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install \
  neovim \
  tmux \
  starship \
  lua \
  luarocks \
  miniforge \
  ripgrep \
  fzf \
  stow

stow -d "$DIR"/.. -t "$HOME" --stow "$DIR/.." -R

tmux source-file $HOME/.config/tmux/tmux.conf

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install \
    karabiner-elements \
    hammerspoon \
    wezterm \
    coreutils

  defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"
fi
