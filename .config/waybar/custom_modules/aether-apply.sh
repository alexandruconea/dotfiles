#!/bin/bash

THEME_DIR="$HOME/.config/aether/theme"

# Generez waybar colors din aether theme
if [ -f "$THEME_DIR/colors.toml" ]; then
    bg=$(grep '^background' "$THEME_DIR/colors.toml" | head -1 | grep -oP '#[0-9a-fA-F]+')
    fg=$(grep '^foreground' "$THEME_DIR/colors.toml" | head -1 | grep -oP '#[0-9a-fA-F]+')
    accent=$(grep '^accent' "$THEME_DIR/colors.toml" | grep -oP '#[0-9a-fA-F]+')
    cat > "$HOME/.config/waybar/aether-colors.css" << EOF
@define-color background ${bg:-#18181b};
@define-color foreground ${fg:-#ffffff};
@define-color highlight ${accent:-#75f1fa};
EOF
fi

# Waybar CSS reload
killall -SIGUSR2 waybar 2>/dev/null

# Mako
if [ -f "$THEME_DIR/mako.ini" ]; then
    cp "$THEME_DIR/mako.ini" "$HOME/.config/mako/config"
    makoctl reload 2>/dev/null
fi

# Hyprland border color
if [ -f "$THEME_DIR/hyprland.conf" ]; then
    color=$(grep 'activeBorderColor' "$THEME_DIR/hyprland.conf" | grep -oP 'rgb\(\w+\)')
    [ -n "$color" ] && hyprctl eval "hl.config({general = {[\"col.active_border\"] = \"$color\"}})" 2>/dev/null
fi

# Wallpaper
wallpaper=$(ls "$THEME_DIR/backgrounds/"*.{jpg,png,webp} 2>/dev/null | head -1)
if [ -n "$wallpaper" ]; then
    WAYLAND_DISPLAY=wayland-1 awww img "$wallpaper" --transition-type fade --transition-duration 1 2>/dev/null
    sed -i "s|^    path = .*|    path = $wallpaper|" "$HOME/.config/hypr/hyprlock.conf"
fi

# Ghostty (update color palette)
if [ -f "$THEME_DIR/ghostty.conf" ]; then
    cp "$THEME_DIR/ghostty.conf" "$HOME/.config/ghostty/colors.conf"
fi

# GTK theme
if [ -f "$THEME_DIR/gtk.css" ]; then
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    cp "$THEME_DIR/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    cp "$THEME_DIR/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    # Notifica aplicatiile GTK sa reîncarce tema
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
fi
