#!/bin/bash

https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
OS=linux-x86_64
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS=macos-arm64
fi

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-"$OS".tar.gz
tar xzf nvim-"$OS".tar.gz
sudo ln -s "($pwd)"/nvim-"$OS"/bin/nvim /usr/local/bin/nvim

