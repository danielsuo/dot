#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install --cask \
  karabiner-elements \
  keyboard-maestro \
  iterm2
