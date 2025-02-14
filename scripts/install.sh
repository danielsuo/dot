#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

pushd "$DIR"

./install_brew.sh
./install_dots.sh
./install_fonts.sh
./install_miniconda.sh
./install_fzf.sh
./install_neovim.sh
./install_starship.sh
./install_tmux.sh

popd
