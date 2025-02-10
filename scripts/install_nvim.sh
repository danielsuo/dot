#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt install neovim
elif [[ "$OSTYPE" == "darwin"* ]]; then
  curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
  tar xzf nvim-macos-arm64.tar.gz
  mv ./nvim-macos-arm64/bin/nvim /usr/local/bin/nvim
  rm -rf nvim-macos-arm64.tar.gz nvim-macos-arm64
fi

git clone git@github.com:danielsuo/dot.nvim.git "$HOME"/.config/nvim
