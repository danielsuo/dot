#!/bin/bash

git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
pushd nerd-fonts

FONT="FiraCode"
git sparse-checkout add patched-fonts/"$FONT"
./install.sh "$FONT"
popd
