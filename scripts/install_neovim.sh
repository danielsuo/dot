#!/bin/bash

OS=linux-x86_64
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS=macos-arm64
fi

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-"$OS".tar.gz
tar xzf nvim-"$OS".tar.gz
sudo ln -s "$(pwd)"/nvim-"$OS"/bin/nvim /usr/local/bin/nvim

