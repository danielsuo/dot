#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt install tmux
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install tmux
fi

git clone git@github.com:tmux-plugins/tpm.git ~/.tmux/plugins/tpm
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
