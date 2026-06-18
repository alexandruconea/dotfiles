#!/bin/bash
# Aplică wallust pe o imagine și reîncarcă toate aplicațiile

exec >> /tmp/wallust-apply.log 2>&1
echo "=== $(date) === IMAGE: $1"

IMAGE="$1"
[ -z "$IMAGE" ] && echo "Usage: wallust-apply.sh <image>" && exit 1
[ ! -f "$IMAGE" ] && echo "File not found: $IMAGE" && exit 1

# Salvează ultimul wallpaper pentru boot
ln -sf "$IMAGE" "$HOME/.config/wallust/last-wallpaper"

# Generează culorile și template-urile
wallust run "$IMAGE" -q

# Setează wallpaper (moștenește WAYLAND_DISPLAY din mediu)
awww img "$IMAGE" --transition-type fade --transition-duration 1 2>/dev/null

# Actualizează culorile direct în style.css și reîncarcă waybar cu SIGUSR2
bg=$(grep 'background' ~/.config/waybar/aether-colors.css | grep -oP '#[0-9a-fA-F]+' | head -1)
fg=$(grep 'foreground' ~/.config/waybar/aether-colors.css | grep -oP '#[0-9a-fA-F]+' | head -1)
hl=$(grep 'highlight' ~/.config/waybar/aether-colors.css | grep -oP '#[0-9a-fA-F]+' | head -1)
STYLE="$HOME/.config/waybar/style.css"
sed -i "s|@define-color background .*|@define-color background $bg;|" "$STYLE"
sed -i "s|@define-color foreground .*|@define-color foreground $fg;|" "$STYLE"
sed -i "s|@define-color highlight .*|@define-color highlight $hl;|" "$STYLE"
pkill -SIGUSR2 waybar 2>/dev/null

# Reîncarcă mako
makoctl reload 2>/dev/null

# Actualizează hyprlock culori și wallpaper
accent="$hl"
if [ -n "$accent" ]; then
    r=$((16#${accent:1:2}))
    g=$((16#${accent:3:2}))
    b=$((16#${accent:5:2}))
    sed -i "s|check_color = .*|check_color = rgba($r, $g, $b, 0.8)|" "$HOME/.config/hypr/hyprlock.conf"
    sed -i "s|outer_color = .*|outer_color = rgba($r, $g, $b, 0.3)|" "$HOME/.config/hypr/hyprlock.conf"
fi
sed -i "s|^    path = .*|    path = $IMAGE|" "$HOME/.config/hypr/hyprlock.conf"

# Actualizează SDDM background (păstrează extensia originală)
EXT="${IMAGE##*.}"
SDDM_BG="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/aether.$EXT"
cp "$IMAGE" "$SDDM_BG" 2>/dev/null
# Actualizează referința din aether.conf dacă extensia s-a schimbat
sed -i "s|^Background=.*|Background=\"Backgrounds/aether.$EXT\"|" \
    /usr/share/sddm/themes/sddm-astronaut-theme/Themes/aether.conf 2>/dev/null

# GTK theme
mkdir -p "$HOME/.config/gtk-3.0"
cp "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css" 2>/dev/null
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null

# SDDM colors
if [ -f "$HOME/.config/wallust/sddm-aether-generated.conf" ]; then
    cp "$HOME/.config/wallust/sddm-aether-generated.conf" \
       /usr/share/sddm/themes/sddm-astronaut-theme/Themes/aether.conf 2>/dev/null
fi

# Actualizează border Hyprland (activ + inactiv)
if [ -n "$accent" ] && [ -n "$bg" ]; then
    hyprctl eval "hl.config({general = {col = {active_border = 'rgba(${accent:1}ee)', inactive_border = 'rgba(${bg:1}aa)'}}})" 2>/dev/null
fi
