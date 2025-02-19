#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

pushd "$DIR"

git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
pushd nerd-fonts
FONT="FiraCode"
git sparse-checkout add patched-fonts/"$FONT"
./install.sh "$FONT"
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

git clone git@github.com:tmux-plugins/tpm.git ~/.config/tmux/plugins/tpm
tmux source-file ~/.config/tmux/tmux.conf
~/.config/tmux/plugins/tpm/bin/install_plugins

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install \
    karabiner-elements \
    hammerspoon \
    wezterm \
    coreutils

  defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
fi

popd
