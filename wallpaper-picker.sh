#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
MONITOR="eDP-1"
THEME="$HOME/.config/rofi/wallpaper.rasi"

SELECTED="$(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort \
        | while read -r file; do
            printf '%s\0icon\x1f%s\n' "$(basename "$file")" "$file"
        done \
        | rofi -dmenu \
            -i \
            -show-icons \
            -p "Wallpaper" \
            -theme "$THEME"
)"

[ -z "$SELECTED" ] && exit 0

WALLPAPER="$WALLPAPER_DIR/$SELECTED"

hyprctl hyprpaper wallpaper "$MONITOR, $WALLPAPER, cover"
