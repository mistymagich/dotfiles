#!/usr/bin/env bash

set -eu

cd ~
git clone https://github.com/mistymagich/dotfiles.git
cd dotfiles
./setup.sh

