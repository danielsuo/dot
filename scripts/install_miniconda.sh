#!/bin/bash

OS=Linux-x86_64

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS=MacOSX-arm64
fi

pushd "$HOME"
mkdir -p miniconda3
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-"$OS".sh -o miniconda3/miniconda.sh
bash miniconda3/miniconda.sh -b -u -p miniconda3
rm miniconda3/miniconda.sh
popd
