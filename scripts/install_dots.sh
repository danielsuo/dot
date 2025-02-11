#!/bin/bash

set -x

DIR="$(dirname "$(readlink -f "$0")")"

pushd "$HOME"
rm -rf .bash_profile .bashrc .tmux.conf .config/starship.toml .config/nvim
popd

ln -s "$DIR"/../.bash_profile "$HOME"/.bash_profile
ln -s "$DIR"/../.bashrc "$HOME"/.bashrc
ln -s "$DIR"/../.tmux.conf "$HOME"/.tmux.conf

mkdir -p "$HOME"/.config
ln -s "$DIR"/../.config/starship.toml "$HOME"/.config/starship.toml
ln -s "$DIR"/../.config/nvim "$HOME"/.config/nvim
