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

# Rofi colors
if [ -n "$bg" ]; then
    # Convert hex to rgba components for rofi (rofi uses hex directly)
    bg_alpha="${bg}e6"
    cat > "$HOME/.config/rofi/colors.rasi" << EOF
* {
    bg:       ${bg:-#18181b};
    fg:       ${fg:-#ffffff};
    accent:   ${accent:-#75f1fa};
    bg-alpha: ${bg_alpha:-#18181be6};
}
EOF
fi

# Waybar CSS reload
killall -SIGUSR2 waybar 2>/dev/null

# Mako colors
if [ -n "$bg" ]; then
    mkdir -p "$HOME/.config/mako"
    cat > "$HOME/.config/mako/config" << EOF
text-color=${fg:-#ffffff}
border-color=${accent:-#75f1fa}
background-color=${bg:-#18181b}
width=420
height=110
padding=10
border-size=2
font=Liberation Sans 11
anchor=top-right
outer-margin=20
default-timeout=5000
max-icon-size=32
[app-name=Spotify]
invisible=1
[mode=do-not-disturb]
invisible=true
[mode=do-not-disturb app-name=notify-send]
invisible=false
EOF
    makoctl reload 2>/dev/null
fi

# Hyprland border color
if [ -f "$THEME_DIR/hyprland.conf" ]; then
    color=$(grep 'activeBorderColor' "$THEME_DIR/hyprland.conf" | grep -oP 'rgb\(\w+\)')
    [ -n "$color" ] && hyprctl eval "hl.config({general = {[\"col.active_border\"] = \"$color\"}})" 2>/dev/null
fi

# Hyprlock colors
if [ -n "$accent" ]; then
    # Convert hex #rrggbb to rgba(r, g, b, a) for hyprlock
    r=$((16#${accent:1:2}))
    g=$((16#${accent:3:2}))
    b=$((16#${accent:5:2}))
    sed -i "s|check_color = .*|check_color = rgba($r, $g, $b, 0.8)|" "$HOME/.config/hypr/hyprlock.conf"
    sed -i "s|outer_color = .*|outer_color = rgba($r, $g, $b, 0.3)|" "$HOME/.config/hypr/hyprlock.conf"
fi

# Wallpaper
wallpaper=$(ls "$THEME_DIR/backgrounds/"*.{jpg,png,webp} 2>/dev/null | head -1)
if [ -n "$wallpaper" ]; then
    WAYLAND_DISPLAY=wayland-1 awww img "$wallpaper" --transition-type fade --transition-duration 1 2>/dev/null
    sed -i "s|^    path = .*|    path = $wallpaper|" "$HOME/.config/hypr/hyprlock.conf"
    cp "$wallpaper" /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/aether.jpg 2>/dev/null
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
