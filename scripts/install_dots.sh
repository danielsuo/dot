#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

ln -s "$DIR"/../.bash_profile "$HOME"/.bash_profile
ln -s "$DIR"/../.bashrc "$HOME"/.bashrc
ln -s "$DIR"/../.tmux.conf "$HOME"/.tmux.conf

mkdir -p "$HOME/.config"
ln -s "$DIR"/../.confg/starship.toml "$HOME/.config/starship.toml"
ln -s "$DIR"/../.confg/nvim "$HOME/.config/nvim"
