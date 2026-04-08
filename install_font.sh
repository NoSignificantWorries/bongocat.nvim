#!/bin/sh

font_dir="$HOME/.local/share/fonts/BongoCat"

mkdir -p "$font_dir"
cp ./BongoCat.ttf "$font_dir"
fc-cache -fv

