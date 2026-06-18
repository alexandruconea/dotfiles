#!/bin/bash
set -e

echo "==> Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
fi

echo "==> Installing packages..."
yay -S --needed - < packages.txt

echo "==> Copying dotfiles..."
cp -r .config/waybar ~/.config/
cp -r .config/ghostty ~/.config/
cp -r .config/mako ~/.config/
cp -r .config/wireplumber ~/.config/
cp .config/hypr/hyprland.lua ~/.config/hypr/

echo "==> Making scripts executable..."
chmod +x ~/.config/waybar/auto-reload.sh
chmod +x ~/.config/waybar/custom_modules/powermenu.sh
chmod +x ~/.config/waybar/custom_modules/media/*.sh

echo ""
echo "Done! Log out and back in to apply all changes."
