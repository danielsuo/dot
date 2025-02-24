#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
pushd nerd-fonts
git sparse-checkout add patched-fonts/FiraCode && ./install.sh FiraCode
popd
rm -rf nerd-fonts

git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/.config/fzf
"$HOME"/.config/fzf/install --xdg --no-bash --no-fish --key-bindings --completion --no-update-rc

if [[ "$OSTYPE" == "darwin"* ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  export BREW_DIR=/opt/homebrew
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt install -y build-essential procps curl file git zsh clang

  if [[ $(command -v gcert) ]]; then
    mkdir -p "BREW_DIR"
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_DIR"

    yes | sudo glinux-add-repo bugged
    sudo apt update
    sudo apt install -y \
      gnubby-wrappers \
      tmux \
      glinux-vim \
      cidermux \
      clsearch \
      bugged

    export BREW_DIR="$HOME"/.linuxbrew
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export BREW_DIR=/home/linuxbrew/.linuxbrew
  fi
  ZSH=$(which zsh)
fi
export BREW="$BREW_DIR"/bin/brew
"$BREW" shellenv
"$BREW" install --force \
  neovim \
  tmux \
  lua \
  luarocks \
  ripgrep \
  stow \
  ripgrep \
  gcc

"$BREW" install --build-from-source \
  jandedobbeleer/oh-my-posh/oh-my-posh

if [[ "$OSTYPE" == "darwin"* ]]; then
  "$BREW" install --force\
      karabiner-elements \
      hammerspoon \
      wezterm \
      coreutils \
      miniforge \
      zsh

  ZSH="$BREW_DIR"/bin/zsh
  defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

  if [[ $(command -v gcert) ]]; then
    sudo mule install roadwarrior
  fi
fi

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b
rm -rf Miniforge3*

"$BREW_DIR"/bin/stow -d "$DIR"/.. -t "$HOME" --stow . -R

git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
if [[ $(command -v tmux) != 0 ]]; then
  TMUX="$BREW_DIR"/bin/tmux
else
  TMUX=tmux
fi
"$TMUX" source-file $HOME/.config/tmux/tmux.conf

echo "$ZSH" >> "$HOME"/.bash_profile

# chrome-untrusted://terminal/html/nassh_preferences_editor.html
# @font-face {font-family: "MesloLGM Nerd Font"; src: url("https://raw.githubusercontent.com/ye-rm/MesloNerdFont-in-chrome-OS/main/MesloLGMNerdFont-Regular.ttf"); font-weight: normal; font-style: normal; unicode-range: U+23fb-23fe, U+2665, U+26a1, U+2b58, U+e000-e00a, U+e0a0-e0a2, U+e0a3, U+e0b0-e0b3, U+e0b4-e0c8, U+e0ca, U+e0cc-e0d4, U+e200-e2a9, U+e300-e3e3, U+e5fa-e6b1, U+e5fa-e6b1, U+e700-e7c5, U+ea60-ebeb, U+f000-f2e0, U+f300-f372, U+f400-f532, U+f500-fd46, U+f0001-f1f0;}
# x-row {
#     text-rendering: optimizeLegibility;
#     font-variant-ligatures: normal;
# }
