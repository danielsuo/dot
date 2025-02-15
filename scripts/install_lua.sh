#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install lua luarocks
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt install lua luarocks
fi
