#!/bin/sh

font_dir="$HOME/.local/share/fonts/BongoCat"

mkdir -p "$font_dir"
cp .lua/fonts/BongoCat.ttf "$font_dir"
fc-cache -fv

